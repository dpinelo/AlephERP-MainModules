Function.prototype.bind = function() {
    var func = this;
    var thisObject = arguments[0];
    var args = Array.prototype.slice.call(arguments, 1);
    return function() {
        return func.apply(thisObject, args);
    }
}

function DBRecordDlg(ui) {
    this.ui = ui;
    this.lineaServicio = null;
    this.calculating = false;

    // Obtenemos y guardamos los objetos más habituales de la UI
    this.tbObservaciones = this.ui.findChild("tbObservaciones");
    this.tbEfectos = this.ui.findChild("tbEfectos");    
    this.tbContabilidad = this.ui.findChild("tbContabilidad");
    this.tbCostes = this.ui.findChild("tbCostes");           
    this.swFichas = this.ui.findChild("swFichas");

    this.tbObservaciones.clicked.connect(this, "showPage");
    this.tbEfectos.clicked.connect(this, "showPage");
    this.tbContabilidad.clicked.connect(this, "showPage");
    this.tbCostes.clicked.connect(this, "showPage");
        
    var beanEmpresaActual = empresaActual();
    this.pbMarcarPagada = this.ui.findChild("pbMarcarPagada");        
    this.tbCostes.visible = beanEmpresaActual.contabilidadcostes.value;
    if ( beanEmpresaActual.contabilidadcostes.value === false ) {
        this.swFichas.setCurrentWidget(this.ui.findChild("pageObservaciones"));
        this.tbObservaciones.checked = true;
    } else {
        this.swFichas.setCurrentWidget(this.ui.findChild("pageCostes"));
        this.tbCostes.checked = true;
    }
    this.pbAgregarMultiplesCentrosCoste = this.ui.findChild("pbAgregarMultiplesCentrosCoste");
    if ( beanEmpresaActual.fieldValue("contintegrada") == false ) {
        this.tbContabilidad.enabled = false;
    } else {
        this.ui.findChild("pbGenerarAsiento").clicked.connect(this, "generarAsientoContable");
    }
    this.pbAgregarMultiplesCentrosCoste.clicked.connect(this, "agregarMultiplesCentrosCoste"); 
    this.pbMarcarPagada.clicked.connect(this, "marcarPagada");                     

    if ( bean.fieldValue("ptepago") == false ) {
        this.pbMarcarPagada.visible = false;
    }

    thisForm.db_servicios_cuotaiva.dataEditable = false;
    thisForm.db_servicios_cuotairpf.dataEditable = false;
    
    // Cuando se guarde una línea, se generan las líneas de IVA
    var relationLineasServicios = bean.relation("lineasservicios" + bean.metadata.tableName);
    //relationLineasServicios['childEndEdit(BaseBean*)'].connect(this, "calcularImpuestos");  
    //relationLineasServicios['childDeleted(BaseBean*,int)'].connect(this, "calcularImpuestos");
    thisForm.db_baseimponible['textChanged(QString)'].connect(this, "setTotal"); 
    thisForm.db_servicios_total['textChanged(QString)'].connect(this, "setBaseImponible");
    thisForm.db_servicios_descripcion.textChanged.connect(this, "setDescripcion");
    //thisForm.db_baseimponible.editingFinished.connect(this, "calcularImpuestos");
    //thisForm.db_servicios_total.editingFinished.connect(this, "calcularImpuestos");    
}


DBRecordDlg.prototype.showPage = function() {
    if ( this.tbObservaciones.checked ) {
        this.swFichas.setCurrentWidget(this.ui.findChild("pageObservaciones"));
    } else if ( this.tbContabilidad.checked ) {
        this.swFichas.setCurrentWidget(this.ui.findChild("pageContabilidad"));
    } else if ( this.tbCostes.checked ) {
        this.swFichas.setCurrentWidget(this.ui.findChild("pageCostes"));
    } else if ( this.tbEfectos.checked ) {
        this.swFichas.setCurrentWidget(this.ui.findChild("pageEfectos"));
    }
}

DBRecordDlg.prototype.validate = function() {
    var beanEmpresaActual = empresaActual();    
    if ( beanEmpresaActual.contabilidadcostes.value == true ) {
        var lineasCostes = bean.relationChildsCount("lineasdistribucioncostes" + bean.metadata.tableName);
        if ( lineasCostes == 0 ) {
            var ret = AERPMessageBox.question("No ha introducido ninguna distribución de costes. ¿Desea guardar sin asignar costes?", AERPMessageBox.Yes | AERPMessageBox.No);
            if ( ret == AERPMessageBox.No ) {
                return false;
            }
        } else {
            // Se comprueba que los cálculos de costes coinciden con el neto.
            if ( !AERPScriptCommon.equalsWithAllowedError(bean.totalcostesdistribuidos.value , bean.neto.value, 0.5) ) {
                var ret = AERPMessageBox.question("Los costes imputados no coinciden con la base imponible de la factura. Esto podría desvirtuar la contabilidad de costes. ¿Está seguro de querer continuar?",
    AERPMessageBox.Yes | AERPMessageBox.No);
                if ( ret == AERPMessageBox.No ) {
                    return false;
                }            
            }
        }
    }
    return true;        
}

DBRecordDlg.prototype.beforeSave = function() {
    // Antes de guardar el formulario maestro, se generan siempre las líneas de IVA y se calculan los IRPF
    this.calcularImpuestos();
    
    if ( !bean.nogenerarasiento.value ) {
        bean.aerpGenerarAsiento.call();
    }
    
    // Ayuda para actualizar la informacion del tercero.
    if ( bean.terceros.father.idplanpago.value != bean.idplanpago.value ) {
        var ret = AERPMessageBox.question("El plan de pago de esta factura no es el plan de pago por defecto definido para el tercero. ¿Desea actualizar la información del tercero asignando como plan de pago el de esta factura?",
                    AERPMessageBox.Yes | AERPMessageBox.No);
        if ( ret == AERPMessageBox.No ) {
            bean.terceros.father.idplanpago.value = bean.idplanpago.value;
        }            
    }

    if ( bean.terceros.father.idserie.value != bean.idserie.value ) {
        var ret = AERPMessageBox.question("La serie de facturación especificada no es la serie de facturación por defecto definida para el tercero. ¿Desea actualizar la información del tercero asignando como serie de facturación la de esta factura?",
                    AERPMessageBox.Yes | AERPMessageBox.No);
        if ( ret == AERPMessageBox.No ) {
            bean.terceros.father.idserie.value = bean.idserie.value;
        }            
    }
    
    return true;
}

DBRecordDlg.prototype.calcularImpuestos = function() {
    var lineas = [];
    var index = 0;
    for (var i = 0 ; i < bean["lineasservicios" + bean.metadata.tableName].items.length ; i++) {
        if ( bean["lineasservicios" + bean.metadata.tableName].items[i].dbState != BaseBean.TO_BE_DELETED && bean["lineasservicios" + bean.metadata.tableName].items[i].dbState != BaseBean.TO_BE_DELETED ) {
            lineas[index] = bean["lineasservicios" + bean.metadata.tableName].items[i];
            index++;
        }
    }
    for (var i = 0 ; i < bean["lineasarticulos" + bean.metadata.tableName].items.length ; i++) {
        if ( bean["lineasarticulos" + bean.metadata.tableName].items[i].dbState != BaseBean.TO_BE_DELETED && bean["lineasarticulos" + bean.metadata.tableName].items[i].dbState != BaseBean.TO_BE_DELETED ) {
            lineas[index] = bean["lineasarticulos" + bean.metadata.tableName].items[i];
            index++;
        }
    }
    alepherp.generarLineasIva(bean, "lineasiva" + bean.metadata.tableName, lineas);
}

DBRecordDlg.prototype.calcularLineasImpuestos = function() {
    var iva = 0;
    var irpf = 0;
    if ( thisForm.db_servicios_iva.value > 0 ) {
        iva = thisForm.db_servicios_iva.value;
        var beanIva = AERPScriptCommon.bean("tvw_periodosimpuestos", "iva=" + iva + " and idempresa=" + bean.idempresa.value + " and now() between fechadesde and fechahasta");
        if ( beanIva != undefined && beanIva != null ) {
            this.lineaServicio.idimpuesto.value = beanIva.id.value;
            this.lineaServicio.iva.value = beanIva.iva.value;
        }
    }
    if ( thisForm.db_servicios_irpf.value > 0 ) {
       irpf = thisForm.db_servicios_irpf.value;
        var beanIrpf = AERPScriptCommon.bean("tvw_periodosimpuestos_irpf", "irpf=" + irpf + " and idempresa=" + bean.idempresa.value + " and now() between fechadesde and fechahasta");
        if ( beanIrpf != undefined && beanIrpf != null ) {
            this.lineaServicio.idimpuesto_irpf.value = beanIrpf.id.value;
            this.lineaServicio.irpf.value = beanIrpf.irpf.value;
        }
    }    
}

DBRecordDlg.prototype.asignarCostes = function() {
    var lineasCostes = bean.relationChilds("lineasdistribucioncostes" + bean.metadata.tableName);
    if ( lineasCostes.length > 0 ) {
        var ret = AERPMessageBox.question("Al escoger una nueva distribución de costes, se borrará la existente. ¿Desea continuar?", AERPMessageBox.Yes | AERPMessageBox.No);
        if ( ret == AERPMessageBox.No ) {
            return;
        }            
    }

    var relationLineasCoste = bean.relation("lineasdistribucioncostes" + bean.metadata.tableName);
    relationLineasCoste.deleteAllChilds();
    var beanDistribucion = thisForm.db_iddistribucioncostes.selectedBean;
    if ( beanDistribucion == null ) {
        return;
    }
    var lineasDistribucion = beanDistribucion.relationChilds("lineasdistribucioncostes");
    for ( var i = 0 ; i < lineasDistribucion.length ; i++ ) {
        var lineaCoste = relationLineasCoste.newChild();
        lineaCoste.setFieldValue("idcentro", lineasDistribucion[i].fieldValue("idcentro"));
        lineaCoste.setFieldValue("nombrecentro", lineasDistribucion[i].fieldValue("descripcioncentro"));
        lineaCoste.setFieldValue("idsubcentro", lineasDistribucion[i].fieldValue("idsubcentro"));
        lineaCoste.setFieldValue("nombresubcentro", lineasDistribucion[i].fieldValue("descripcionsubcentro"));
        lineaCoste.setFieldValue("porcentaje", lineasDistribucion[i].fieldValue("pordistribucioncoste"));
        lineaCoste.setFieldValue("importe", (lineasDistribucion[i].fieldValue("pordistribucioncoste") / 100) * bean.fieldValue("neto"));
    }
}

DBRecordDlg.prototype.agregarMultiplesCentrosCoste = function() {
    var dlg = new DBDialog;
    dlg.type = "script";
    dlg.uiName = "facturasprovagregarsubcentroscoste.view.ui";
    dlg.qsName = "facturasprovagregarsubcentroscoste.view.qs";
    dlg.addPropertyObjectToThisForm("beanFactura", bean);
    dlg.show();
}

DBRecordDlg.prototype.servicioSelected = function() {
    var beanServicio = thisForm.db_chooseidservicio.selectedBean;
    thisForm.db_lineidservicio.value = beanServicio.referencia.value;
    this.addServicio(beanServicio);           
}

DBRecordDlg.prototype.servicioReferenciaSelected = function() {
    var beanServicio = thisForm.db_lineidservicio.completerSelectedBean;
    this.addServicio(beanServicio);
}

DBRecordDlg.prototype.marcarPagada = function() {
}

DBRecordDlg.prototype.idterceroValueModified = function() {
    if ( bean.idserie.value == 0 && bean.terceros.father.idserie.value > 0 ) {
        bean.idserie.value = bean.terceros.father.idserie.value;
        bean.idplanpago.value = bean.terceros.father.idplanpago.value;
    }
}

DBRecordDlg.prototype.addServicio = function(beanServicio) {
    if ( beanServicio.idempresa.value != bean.idempresa.value ) {
        return;
    }
    
    if ( beanServicio == null ) {
        if ( this.lineaServicio != null ) {
            this.lineaServicio.idservicio = 0;
            thisForm.db_servicios_nombre.value = "";
            thisForm.db_servicios_iva.value = 0;
            thisForm.db_servicios_irpf.value = 0;
            this.lineaServicio.idimpuesto.value = 0;
            this.lineaServicio.idimpuesto_irpf.value = 0;
            this.lineaServicio.tipooperacioniva.value = "";
            this.lineaServicio.tipoiva.value = "";
            this.lineaServicio.iva.value = 0;
            this.lineaServicio.irpf.value = 0;
            this.lineaServicio.descripcion.value = "";
            this.lineaServicio.horas.value = 0;
            this.lineaServicio.importeunitario.value = 0;
            this.lineaServicio.idsubcuenta.value = 0;
        }
        return;
    } else {
        if ( beanServicio.idtercerocompra.terceros.father.dbState == BaseBean.UPDATE && 
             beanServicio.idtercerocompra.terceros.father.idempresa.value == bean.idempresa.value ) {
            bean.idtercero.value = beanServicio.idtercerocompra.value;
            bean.nombre.value = beanServicio.idtercerocompra.terceros.father.nombre.value;
            bean.cifnif.value = beanServicio.idtercerocompra.terceros.father.cifnif.value;
        }
        if ( beanServicio.idseriecompra.value == 0 || beanServicio.idseriecompra.value === undefined || beanServicio.idseriecompra.value == null ) {
        } else {
            if ( beanServicio.idseriecompra.seriesfacturacion.father.dbState == BaseBean.UPDATE && 
                 beanServicio.idseriecompra.seriesfacturacion.father.idempresa.value == bean.idempresa.value ) {
                if ( bean.idserie.value != beanServicio.idseriecompra.value ) {
                    bean.idserie.value = beanServicio.idseriecompra.value;
                    // Avisamos de que se va a cambiar la serie de facturacion... y por tanto puede cambiar el codigo.
                    thisForm.db_idserie.askToRecalculateCounterField();
                }
            }
        }
        if ( beanServicio.idtercerocompra.terceros.father.planespago.father.dbState == BaseBean.UPDATE && 
             beanServicio.idtercerocompra.terceros.father.planespago.father.idempresa.value == bean.idempresa.value ) {
            bean.idplanpago.value = beanServicio.idtercerocompra.terceros.father.idplanpago.value;
        }
        thisForm.db_servicios_nombre.value = beanServicio.nombre.value;
        thisForm.db_servicios_iva.value = beanServicio.impuestoscompra.father.iva.value;
        thisForm.db_servicios_irpf.value = beanServicio.idirpfcompra.impuestos_irpf.father.irpf.value;
    }
    if ( this.lineaServicio == null ) {
        this.lineaServicio = bean.lineasserviciosfacturasprov.newChild();
    }
    this.lineaServicio.idservicio.value = beanServicio.id.value;
    this.lineaServicio.idimpuesto.value = beanServicio.idimpuestocompra.value;
    this.lineaServicio.idimpuesto_irpf.value = beanServicio.idirpfcompra.value;
    this.lineaServicio.tipooperacioniva.value = beanServicio.tipooperacioniva.value;
    this.lineaServicio.tipoiva.value = beanServicio.tipoiva.value;
    this.lineaServicio.iva.value = beanServicio.impuestoscompra.father.iva.value;
    this.lineaServicio.irpf.value = beanServicio.idirpfcompra.impuestos_irpf.father.irpf.value;
    this.lineaServicio.descripcion.value = beanServicio.descripcion.value;
    this.lineaServicio.horas.value = 1;
    this.lineaServicio.importeunitario.value = thisForm.db_baseimponible.value;
    this.lineaServicio.idsubcuenta.value = beanServicio.idsubcuentacompras.value;
    this.calcularImpuestos();
}

DBRecordDlg.prototype.setTotal = function() {
    if ( this.calculating ) {
        return;
    }
    if ( this.lineaServicio == null ) {
        this.lineaServicio = bean.lineasserviciosfacturasprov.newChild();
        this.lineaServicio.horas.value = 1;
    }
    this.lineaServicio.importeunitario.value = thisForm.db_baseimponible.value;
    var iva = 0;
    var irpf = 0;
    if ( thisForm.db_servicios_iva.value > 0 ) {
        iva = thisForm.db_servicios_iva.value;
    }
    if ( thisForm.db_servicios_irpf.value > 0 ) {
       irpf = thisForm.db_servicios_irpf.value;
    }
    this.calculating = true;
    thisForm.db_servicios_total.value = thisForm.db_baseimponible.value * (1 + (iva / 100) - (irpf / 100));
    thisForm.db_servicios_cuotaiva.value = thisForm.db_baseimponible.value * iva / 100;
    thisForm.db_servicios_cuotairpf.value = thisForm.db_baseimponible.value * irpf / 100;
    this.lineaServicio.importeunitario.value = thisForm.db_baseimponible.value;
    this.calcularLineasImpuestos();
    this.calculating = false;
}

DBRecordDlg.prototype.setBaseImponible = function() {
    if ( this.calculating ) {
        return;
    }
    if ( this.lineaServicio == null ) {
        this.lineaServicio = bean.lineasserviciosfacturasprov.newChild();
        this.lineaServicio.horas.value = 1;
    }
    var iva = 0;
    var irpf = 0;
    if ( thisForm.db_servicios_iva.value > 0 ) {
        iva = thisForm.db_servicios_iva.value;
    }
    if ( thisForm.db_servicios_irpf.value > 0 ) {
        irpf = thisForm.db_servicios_irpf.value;
    }
    this.calculating = true;
    thisForm.db_baseimponible.value = thisForm.db_servicios_total.value / (1 + (iva / 100) - (irpf / 100));
    thisForm.db_servicios_cuotaiva.value = thisForm.db_baseimponible.value * iva / 100;
    thisForm.db_servicios_cuotairpf.value = thisForm.db_baseimponible.value * irpf / 100;
    this.lineaServicio.importeunitario.value = thisForm.db_baseimponible.value;
    this.calcularLineasImpuestos();
    this.calculating = false;
}

DBRecordDlg.prototype.setDescripcion = function() {
    if ( this.lineaServicio == null ) {
        this.lineaServicio = bean.lineasserviciosfacturasprov.newChild();
        this.lineaServicio.horas.value = 1;
    }
    this.lineaServicio.descripcion.value = thisForm.db_servicios_descripcion.value;
}

DBRecordDlg.prototype.updateIVA = function(selectedBean) {
    if ( this.lineaServicio != null && selectedBean != null ) {
        this.lineaServicio.idimpuesto.value = selectedBean.id.value;
        this.lineaServicio.iva.value = selectedBean.iva.value;
        thisForm.db_servicios_iva.value = selectedBean.iva.value;
        thisForm.db_servicios_cuotaiva.value = thisForm.db_baseimponible.value * thisForm.db_servicios_iva.value / 100;
        thisForm.db_servicios_total.value = thisForm.db_baseimponible.value * (1 + (thisForm.db_servicios_iva.value / 100) - (thisForm.db_servicios_irpf.value / 100));
        this.calcularImpuestos();
    }
}

DBRecordDlg.prototype.updateIRPF = function(selectedBean) {
    if ( this.lineaServicio != null && selectedBean != null ) {
        this.lineaServicio.idimpuesto_irpf.value = selectedBean.id.value;
        this.lineaServicio.irpf.value = selectedBean.irpf.value;
        thisForm.db_servicios_irpf.value = selectedBean.irpf.value;
        thisForm.db_servicios_cuotairpf.value = thisForm.db_baseimponible.value * thisForm.db_servicios_irpf.value / 100;
        thisForm.db_servicios_total.value = thisForm.db_baseimponible.value * (1 + (thisForm.db_servicios_iva.value / 100) - (thisForm.db_servicios_irpf.value / 100));
        this.calcularImpuestos();
    }
}

DBRecordDlg.prototype.generarAsientoContable = function() {
    if ( !bean.nogenerarasiento.value && !bean.seriesfacturacion.father.ignoracontabilidad.value ) {
        this.calcularImpuestos();
        bean.aerpGenerarAsiento.call();
    } else {
        var asiento = bean.co_asientos.brother;
        if ( asiento != null ) {
            asiento.dbState = BaseBean.TO_BE_DELETED;
            asiento.touch();
        }    
    }
}

DBRecordDlg.prototype.lineasdistribucioncostesfacturasprovbeforeAddChild = function() {
    this.calcularImpuestos();
}
