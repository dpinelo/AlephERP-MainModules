Function.prototype.bind = function() {
    var func = this;
    var thisObject = arguments[0];
    var args = Array.prototype.slice.call(arguments, 1);
    return function() {
        return func.apply(thisObject, args);
    }
}

alepherp.DBRecordDlgDocumentosGestion = function() {
}

alepherp.DBRecordDlgDocumentosGestion.prototype.init = function(ui) {
    AERPLoadExtension("alepherp.almacen");
    this.ui = ui;

    // Obtenemos y guardamos los objetos más habituales de la UI
    this.tbDatos = this.ui.findChild("tbDatos");
    this.tbLineas = this.ui.findChild("tbLineas");
    this.tbObservaciones = this.ui.findChild("tbObservaciones");
    this.swFichas = this.ui.findChild("swFichas");
    
    this.swFichas.setCurrentWidget(this.ui.findChild("pageDatos"));
    this.tbDatos.checked = true;

    this.tbDatos.clicked.connect(this, "showPage");
    if ( this.tbLineas != null ) {
        this.tbLineas.clicked.connect(this, "showPage");
    }
    if ( this.tbObservaciones != null ) {
        this.tbObservaciones.clicked.connect(this, "showPage");
    }

    this.tbEfectos = this.ui.findChild("tbEfectos");  
    if ( this.tbEfectos != null ) { 
        this.tbEfectos.clicked.connect(this, "showPage");
    }

    if ( bean.metadata.tableName == "facturasprov" || bean.metadata.tableName == "facturascli" ||
         bean.metadata.tableName == "albaranesprov" || bean.metadata.tableName == "albaranescli" ) {
        this.pbMarcarPagada = this.ui.findChild("pbMarcarPagada");
        if ( this.pbMarcarPagada != null ) {
            if ( thisForm.openType != AlephERP.ReadOnly ) {
                this.pbMarcarPagada.clicked.connect(this, "marcarPagada");
            } else {
                this.pbMarcarPagada.visible = false;
            }
        }
        if ( bean.fieldValue("ptepago") == false ) {
            this.pbMarcarPagada.visible = false;
        }              
    }
    if ( bean.metadata.tableName == "pedidoscli" || bean.metadata.tableName == "pedidosprov" ) {
        this.tbAlbaranes = this.ui.findChild("tbAlbaranes");
        this.tbAlbaranes.clicked.connect(this, "showPage");
    }
    if ( bean.metadata.tableName == "albaranesprov" || bean.metadata.tableName == "albaranescli" ) {
        this.tbStocks = this.ui.findChild("tbStocks");
        this.tbStocks.clicked.connect(this, "showPage");
    }
    if ( bean.metadata.tableName == "facturasprov" || bean.metadata.tableName == "facturascli" ) {
        var beanEmpresaActual = empresaActual();
        this.tbContabilidad = this.ui.findChild("tbContabilidad");
        this.tbCostes = this.ui.findChild("tbCostes");           
        this.tbCostes.visible = beanEmpresaActual.contabilidadcostes.value;
        this.pbAgregarMultiplesCentrosCoste = this.ui.findChild("pbAgregarMultiplesCentrosCoste");
        this.tbContabilidad.clicked.connect(this, "showPage");
        this.tbCostes.clicked.connect(this, "showPage");
        if ( beanEmpresaActual.fieldValue("contintegrada") == false ) {
            this.tbContabilidad.enabled = false;
        }
        if ( thisForm.openType != AlephERP.ReadOnly ) {
            if ( this.ui.findChild("pbGenerarAsiento") != undefined && this.ui.findChild("pbGenerarAsiento") != null ) {
                this.ui.findChild("pbGenerarAsiento").clicked.connect(this, "generarAsientoContable");
            }
            this.pbAgregarMultiplesCentrosCoste.clicked.connect(this, "agregarMultiplesCentrosCoste"); 
        } else {
            this.pbAgregarMultiplesCentrosCoste.visible = false;
        }
    }
        
    if ( bean.dbState == BaseBean.INSERT ) {
        thisForm.db_iddirtercero.enabled = false;
    } else {
        thisForm.db_iddirtercero.beanSearchList = bean.terceros.father;
        if ( bean.metadata.tableName == "facturasprov" || bean.metadata.tableName == "facturascli" ) {
            this.setColorForIVAField();
        }
        var efectos = undefined;
        if ( bean.metadata.tableName == "facturasprov" ) {
            efectos = bean.getRelatedElementsByCategory("Pagos");
        } else if ( bean.metadata.tableName == "facturascli" ) {
            efectos = bean.getRelatedElementsByCategory("Cobros");
        }
        if ( efectos != undefined ) {
            for (var i = 0 ; i < efectos.length ; i++) {
                if ( efectos[i].hasCategory("Albaranes") ) {
                    if ( bean.metadata.tableName == "facturasprov" ) {
                        thisForm.db_efectospagoautomaticos.visible = false;
                    } else if ( bean.metadata.tableName == "facturascli" ) {
                        thisForm.db_efectoscobroautomaticos.visible = false;
                    }
                }
            }
        }
        if ( bean.metadata.tableName == "albaranesprov" || bean.metadata.tableName == "albaranescli" ) {
            if ( bean.idalbaranrect.value > 0 ) {
                thisForm.db_codrect.value = bean[bean.metadata.tableName].father.codalbaran.value;
            }
        }
        if ( bean.metadata.tableName == "facturasprov" || bean.metadata.tableName == "facturascli" ) {
            if ( bean.idfacturarect.value > 0 ) {
                thisForm.db_codrect.value = bean[bean.metadata.tableName].father.codfactura.value;
            }
        }
    }
    
    if ( bean.metadata.tableName == "albaranesprov" || bean.metadata.tableName == "albaranescli" ) {
        if ( thisForm.hasOwnProperty("db_idalbaranrect") ) {
            thisForm.db_idalbaranrect.dataEditable = bean.deabono.value;
        }
    }
    if ( bean.metadata.tableName == "facturasprov" || bean.metadata.tableName == "facturascli" ) {
        thisForm.db_idfacturarect.dataEditable = bean.deabono.value;
    }
    
    if ( thisForm.hasOwnProperty("db_introrapidaarticulos") ) {
        thisForm.db_introrapidaarticulos["textEdited(QString)"].connect(this, "introRapidaArticulos");
    }
    if ( this.ui.findChild("pbGenerarStock") != null ) {
        if ( thisForm.openType != AlephERP.ReadOnly ) {
            this.ui.findChild("pbGenerarStock").clicked.connect(this, "generarStock");
        } else {
            this.ui.findChild("pbGenerarStock").visible = false;;
        }
    }
}

alepherp.DBRecordDlgDocumentosGestion.prototype.showPage = function() {
    if ( this.tbDatos.checked ) {
        this.swFichas.setCurrentWidget(this.ui.findChild("pageDatos"));
    } else if ( this.tbLineas != null && this.tbLineas.checked ) {
        this.swFichas.setCurrentWidget(this.ui.findChild("pageLineas"));
    } else if ( this.tbObservaciones != null && this.tbObservaciones.checked ) {
        this.swFichas.setCurrentWidget(this.ui.findChild("pageObservaciones"));
    } else if ( (bean.metadata.tableName == "pedidosprov" || bean.metadata.tableName == "pedidoscli") && this.tbAlbaranes.checked ) {
        this.swFichas.setCurrentWidget(this.ui.findChild("pageAlbaranes"));
    } else if ( (bean.metadata.tableName == "albaranesprov" || bean.metadata.tableName == "albaranescli") && this.tbStocks.checked ) {
        this.swFichas.setCurrentWidget(this.ui.findChild("pageStocks"));
    } else if ( (bean.metadata.tableName == "facturasprov" || bean.metadata.tableName == "facturascli") && this.tbContabilidad.checked ) {
        this.swFichas.setCurrentWidget(this.ui.findChild("pageContabilidad"));
    } else if ( (bean.metadata.tableName == "facturasprov" || bean.metadata.tableName == "facturascli") && this.tbCostes.checked ) {
        this.swFichas.setCurrentWidget(this.ui.findChild("pageCostes"));
    } else if ( (bean.metadata.tableName == "facturasprov" || bean.metadata.tableName == "facturascli" ||
                 bean.metadata.tableName == "albaranescli" || bean.metadata.tableName == "albaranesprov" ) && this.tbEfectos != null && this.tbEfectos.checked ) {
        this.swFichas.setCurrentWidget(this.ui.findChild("pageEfectos"));
        if ( bean.metadata.tableName == "facturasprov" ) {
            this.efectospagoautomaticosValueModified();
        } else if ( bean.metadata.tableName == "facturascli" ) {
            this.efectoscobroautomaticosValueModified();
        }
    }
}

alepherp.DBRecordDlgDocumentosGestion.prototype.validate = function() {
    var beanEmpresaActual = empresaActual();    
    if ( bean.metadata.tableName == "facturasprov" && beanEmpresaActual.contabilidadcostes.value == true ) {
        var lineasCostes = bean.relationChildsCount("lineasdistribucioncostes" + bean.metadata.tableName);
        if ( lineasCostes == 0 ) {
            var ret = AERPMessageBox.question("No ha introducido ninguna distribución de costes. ¿Desea guardar sin asignar costes?", AERPMessageBox.Yes | AERPMessageBox.No);
            if ( ret == AERPMessageBox.No ) {
                return false;
            }
        }
        // Se comprueba que los cálculos de costes coinciden con el neto.
        if ( !AERPScriptCommon.equalsWithAllowedError(bean.totalcostesdistribuidos.value, bean.neto.value, 0.5) ) {
            var ret = AERPMessageBox.question("Los costes imputados no coinciden con la base imponible de la factura. Esto podría desvirtuar la contabilidad de costes. ¿Está seguro de querer continuar?",
                AERPMessageBox.Yes | AERPMessageBox.No);
            if ( ret == AERPMessageBox.No ) {
                return false;
            }            
        }
    }
    return true;        
}

alepherp.DBRecordDlgDocumentosGestion.prototype.beforeSave = function() {
    return true;
}

alepherp.DBRecordDlgDocumentosGestion.prototype.beanSaved = function() {
    return;
}

alepherp.DBRecordDlgDocumentosGestion.prototype.beforeNavigate = function() {
    return true;
}

alepherp.DBRecordDlgDocumentosGestion.prototype.afterNavigate = function() {
    return;
}

alepherp.DBRecordDlgDocumentosGestion.prototype.beforeSelectTercero = function(chooseButton) {
    if ( bean.metadata.tableName == "facturasprov" || bean.metadata.tableName == "albaranesprov" ) {
        chooseButton.addDefaultValue("tipo", "PR");
    } else if ( bean.metadata.tableName == "facturascli" || bean.metadata.tableName == "albaranescli" ) {
        chooseButton.addDefaultValue("tipo", "CL");
    }
}

alepherp.DBRecordDlgDocumentosGestion.prototype.terceroWasSelected = function() {
    var beanTercero = thisForm.db_idtercero.selectedBean;
    if ( beanTercero != null ) {
        if ( bean.metadata.tableName == "facturasprov" || bean.metadata.tableName == "facturascli" ) {
            if ( bean.idserie.value == 0 ) {
                bean.idserie.value = beanTercero.idserie.value;
            }
            if ( bean.fieldValue("idplanpago") == 0 ) {
                bean.idplanpago.value = beanTercero.idplanpago.value;
            }
        }
        bean.iddirtercero.value = 0;
        bean.nombredirtercero.value = "";
        thisForm.db_iddirtercero.beanSearchList = beanTercero;
        thisForm.db_iddirtercero.clear();
        if ( beanTercero.dirterceros.children.length == 1 ) {
            thisForm.db_iddirtercero.selectedBean = beanTercero.dirterceros.children[0];
        }
    }
}

alepherp.DBRecordDlgDocumentosGestion.prototype.idterceroValueModified = function() {
    thisForm.db_iddirtercero.enabled = true;
}

alepherp.DBRecordDlgDocumentosGestion.prototype.updateTasaConv = function() {
    var beanDivisa = thisForm.db_coddivisa.selectedBean;
    if ( beanDivisa != null ) {
        bean.tasaconv.value = beanDivisa.tasaconv.value;
    }
}

alepherp.DBRecordDlgDocumentosGestion.prototype.asignarCostes = function() {
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
        lineaCoste.setFieldValue("total", (lineasDistribucion[i].fieldValue("pordistribucioncoste") / 100) * bean.fieldValue("total"));
    }
}

alepherp.DBRecordDlgDocumentosGestion.prototype.efectoscobroautomaticosValueModified = function() {
    if ( bean.efectoscobroautomaticos.modified ) {
        if ( bean.efectoscobroautomaticos.value == true ) {
            thisForm.db_efectoscobro.visibleButtons = DBDetailView.ViewButton;
            this.pbMarcarPagada.visible = false;
            bean.aerpGenerarEfectos.call();
        } else {
            thisForm.db_efectoscobro.visibleButtons = DBDetailView.InsertButton | DBDetailView.UpdateButton | DBDetailView.DeleteButton | 
                                                      DBDetailView.ViewButton | DBDetailView.InsertExistingButton | DBDetailView.RemoveExistingButton;
            if ( thisForm.openType != AlephERP.ReadOnly ) {
                this.pbMarcarPagada.visible = true;
            }
        }
    }
}

alepherp.DBRecordDlgDocumentosGestion.prototype.efectospagoautomaticosValueModified = function() {
    if ( bean.efectospagoautomaticos.modified ) {
        if ( bean.efectospagoautomaticos.value == true ) {
            thisForm.db_efectospago.visibleButtons = DBDetailView.ViewButton;
            this.pbMarcarPagada.visible = false;
            bean.aerpGenerarEfectos.call();
        } else {
            thisForm.db_efectospago.visibleButtons = DBDetailView.InsertButton | DBDetailView.UpdateButton | DBDetailView.DeleteButton | 
                                                     DBDetailView.ViewButton | DBDetailView.InsertExistingButton | DBDetailView.RemoveExistingButton;
            if ( thisForm.openType != AlephERP.ReadOnly ) {
                this.pbMarcarPagada.visible = true;
            }
        }
    }
}

alepherp.DBRecordDlgDocumentosGestion.prototype.marcarPagada = function() {
    if ( bean.modified ) {
        var ret = AERPMessageBox.question("Para marcar la factura como pagada, debe guardarse primero. ¿Desea guardarla?", AERPMessageBox.Yes | AERPMessageBox.No);
        if ( ret ==  AERPMessageBox.No ) {
            return;
        }
        if ( !thisForm.save() ) {
            return;
        }
    }
    // Solicitemos al usuario la forma de pago
    var formaPago = AERPScriptCommon.chooseRecordFromComboBox("formaspago", "descripcion", "idempresa=" + AERPScriptCommon.envVar("idempresa"), "descripcion ASC", "Seleccione la forma de pago");
    if ( formaPago != null ) {
        bean.aerpMarcarPagada.call(formaPago);
    }
}

alepherp.DBRecordDlgDocumentosGestion.prototype.idserieValueModified = function() {
    this.setColorForIVAField();
}

alepherp.DBRecordDlgDocumentosGestion.prototype.idplanpagoValueModified = function() {
    if ( bean.hasOwnProperty("aerpGenerarEfectos") ) {
        bean.aerpGenerarEfectos.call();
    }
}

alepherp.DBRecordDlgDocumentosGestion.prototype.setColorForIVAField = function() {
    // Cuando se agrega una serie de facturación que está exenta de IVA, se marcan los campos de IVA con un color especial
    // para destacar al usuario que en ellos no debe de haber valores.
    if ( bean.seriesfacturacion.father.tipoiva.value != "Sujeta a I.V.A." ) {
        thisForm.db_totaliva.styleSheet = "background:#FFF395";
    } else {
        thisForm.db_totaliva.styleSheet = "background:#FFFFFF";
    }
}

alepherp.DBRecordDlgDocumentosGestion.prototype.agregarMultiplesCentrosCoste = function() {
    var dlg = new DBDialog;
    dlg.type = "script";
    dlg.uiName = "facturasprovagregarsubcentroscoste.view.ui";
    dlg.qsName = "facturasprovagregarsubcentroscoste.view.qs";
    dlg.addPropertyToThisForm("beanFactura", bean);
    dlg.show();
}

alepherp.DBRecordDlgDocumentosGestion.prototype.lineasserviciosfacturasprovModifiedChild = function() {
    bean.aerpCalcularImpuestos.call();
}

alepherp.DBRecordDlgDocumentosGestion.prototype.lineasarticulosfacturasprovModifiedChild = function() {
    bean.aerpCalcularImpuestos.call();
}

alepherp.DBRecordDlgDocumentosGestion.prototype.lineasserviciosfacturascliModifiedChild = function() {
    bean.aerpCalcularImpuestos.call();
}

alepherp.DBRecordDlgDocumentosGestion.prototype.lineasarticulosfacturascliModifiedChild = function() {
    bean.aerpCalcularImpuestos.call();
}

alepherp.DBRecordDlgDocumentosGestion.prototype.introRapidaArticulos = function() {
    if ( thisForm.db_introrapidaarticulos.text == "" ) {
        return;
    }
    if ( bean.idubicacion.value == 0 ) {
        AERPMessageBox.information("Debe escoger una ubicació de almacén por defecto, desde el que escoger los artículos.");
        return;
    }
    var objArticulo = alepherp.almacen.articuloOInstanciaPorReferencia(thisForm.db_introrapidaarticulos.value);
    if ( objArticulo != null ) {
        var mensaje;
        if ( objArticulo.isInstancia  ) {
            mensaje = alepherp.almacen.esPosibleSalidaArticulo(objArticulo.instancia, bean.idubicacion.value);
        }
        if ( !objArticulo.isInstancia ) {
            mensaje = alepherp.almacen.esPosibleSalidaArticulo(objArticulo.articulo, bean.idubicacion.value);
        }
        if ( mensaje != "" ) {
            AERPMessageBox.information(mensaje + " No puede ser agregado.");
            return;
        }
        var linea = bean["lineasarticulos" + bean.metadata.tableName].newChild();
        if ( objArticulo.isInstancia ) {
            linea.articulosinstancias.father = objArticulo.instancia;
            linea.articulos.father = objArticulo.instancia.articulos.father;
            linea.idubicacion.father = objArticulo.instancia.idubicacion.value;
        } else {
            linea.articulos.father = objArticulo.articulo;
        }
        linea.cantidad.value = 1;
        linea.importeunitario.value = objArticulo.articulo.pvp.value;
        thisForm.db_introrapidaarticulos.text = "";
    }
}

alepherp.DBRecordDlgDocumentosGestion.prototype.agregarAlbaran = function() {
    var albaran = thisForm.db_idalbaran.selectedBean;
    var tableOriginal;
    if ( bean.metadata.tableName == "facturasprov" ) {
        tableOriginal = "prov";
    } else if (bean.metadata.tableName == "facturascli") {
        tableOriginal = "cli";
    } else {
        return;
    }
    // Primero, ¿los terceros coinciden?
    if ( bean.idtercero.value == 0 ) {
        bean.copyValues(albaran, "idtercero", "iddirtercero", "nombre", "cifnif", "nombredirtercero", "direccion", "codpostal", "codpais", "provincia");
    } else if ( bean.idtercero.value != albaran.idtercero.value && albaran.idtercero.value > 0 ) {
        var ret = AERPMessageBox.question("El albarán se ha emitido a un tercero diferente al asignado actualmente a esta factura. ¿Está seguro de que desea continuar agregándolo?", AERPMessageBox.Yes | AERPMessageBox.No);
        if ( ret == AERPMessageBox.No ) {
            return;
        }
    }
    if (bean.hasOwnProperty("idtarifa")) {
        if ( bean.idtarifa.value == 0 ) {
            bean.idtarifa.value = albaran.idtarifa.value;
        } else if ( bean.idtarifa.value != albaran.idtarifa.value && albaran.idtarifa.value > 0 ) {
            var ret = AERPMessageBox.information("La tarifa asignada en el albarán no coincide con la asignada en la factura. Las líneas se agregarán con los importas asignados y tarificados según el albarán.");
        }
    }
    AERPScriptCommon.waitCursor();
    // Vamos a agregar las líneas de artículos o servicios a partir del albarán
    for ( var i = 0 ; i < albaran["lineasarticulosalbaranes" + tableOriginal].items.length ; i++ ) {
        var linea = albaran["lineasarticulosalbaranes" + tableOriginal].items[i];
        if ( linea.idlineafactura.value == 0 ) {
            var lineaFactura = bean["lineasarticulos" + bean.metadata.tableName].newChild();
            lineaFactura.copyValues(linea);
            lineaFactura.idlineaalbaran.value = linea.id.value;
            linea["lineasarticulosfacturas" + tableOriginal].father = lineaFactura;
        }
    }
    for ( var i = 0 ; i < albaran["lineasserviciosalbaranes" + tableOriginal].items.length ; i++ ) {
        var linea = albaran["lineasservicios" + bean.metadata.tableName].items[i];
        if ( linea.idlineafactura.value == 0 ) {
            var lineaFactura = bean["lineasservicios" + bean.metadata.tableName].newChild();
            lineaFactura.copyValues(linea);
            lineaFactura.idlineaalbaran.value = linea.id.value;
            linea["lineasserviciosfacturas" + tableOriginal].father = lineaFactura;
        }
    }  
    // ¿El albarán tiene efectos de pago? Si es así, los vamos a relacionar también con esta factura.
    var efectos;
    if ( bean.metadata.tableName == "facturasprov" || bean.metadata.tableName == "albaranesprov" ) {
        efectos = albaran.getRelatedElementsByCategory("Pagos");
    } else if ( bean.metadata.tableName == "facturascli" || bean.metadata.tableName == "albaranescli" ) {
        efectos = albaran.getRelatedElementsByCategory("Cobros");
    }
    for ( var i = 0 ; i < efectos.length ; i++ ) {
        var element = bean.newRelatedElement(efectos[i]);
        element.additionalInfo = "Efecto de pago creado para Albarán con número: " + albaran.codalbaran.value;
    }
    // Cuando el albarán arrastra ya un efecto de pago, no tiene sentido aplicar la generación automática de efectos
    if ( efectos.length > 0 ) {
        if ( bean.metadata.tableName == "facturasprov" ) {
            thisForm.db_efectospagoautomaticos.visible = false;
            bean.efectospagoautomaticos.value = false;
        } else if ( bean.metadata.tableName == "facturascli" ) {
            thisForm.db_efectoscobroautomaticos.visible = false;
            bean.efectoscobroautomaticos.value = false;
        }
    }
    AERPScriptCommon.restoreCursor();
}

alepherp.DBRecordDlgDocumentosGestion.prototype.db_idalbaranBeforeChoose = function() {
    this.construirFiltroAlbaranes();  
}

alepherp.DBRecordDlgDocumentosGestion.prototype.db_idalbaranAfterChoose = function(albaran) {
    thisForm.db_idalbaran.value = albaran.codalbaran.value;
    this.agregarAlbaran();
}

alepherp.DBRecordDlgDocumentosGestion.prototype.generarStock = function() {
    if ( bean.hasOwnProperty("aerpGenerarEntradasStock") ) {
        bean.aerpGenerarEntradaStock.call();
    }
}

alepherp.DBRecordDlgDocumentosGestion.prototype.obtenerAlbaranesAgregados = function() {
    var idalbaranes = new Array();
    var tableOriginal;
    if ( bean.metadata.tableName == "facturasprov" ) {
        tableOriginal = "prov";
    } else if (bean.metadata.tableName == "facturascli") {
        tableOriginal = "cli";
    } else {
        return idalbaranes;
    }
    // Vamos a agregar las líneas de artículos o servicios a partir del albarán
    for ( var i = 0 ; i < bean["lineasarticulosfacturas" + tableOriginal].items.length ; i++ ) {
        var idalbaran = bean["lineasarticulosfacturas" + tableOriginal].items[i]["lineasarticulosalbaranes" + tableOriginal].father["albaranes" + tableOriginal].father.id.value;
        if ( idalbaranes.indexOf(idalbaran) == -1 ) {
            idalbaranes[idalbaranes.length] = idalbaran;
        }
    }
    for ( var i = 0 ; i < bean["lineasserviciosfacturas" + tableOriginal].items.length ; i++ ) {
        var idalbaran = bean["lineasserviciosfacturas" + tableOriginal].items[i]["lineasserviciosalbaranes" + tableOriginal].father["albaranes" + tableOriginal].father.id.value;
        if ( idalbaranes.indexOf(idalbaran) == -1 ) {
            idalbaranes[idalbaranes.length] = idalbaran;
        }
    } 
    return idalbaranes;  
}

alepherp.DBRecordDlgDocumentosGestion.prototype.construirFiltroAlbaranes = function() {
    var sqlFiltro = "id not in (";
    var hayFiltro = false;
    var idalbaranes = this.obtenerAlbaranesAgregados();
    for ( var i = 0 ; i < idalbaranes.length ; i++ ) {
        if ( sqlFiltro != "id not in (") {
             sqlFiltro = sqlFiltro + ",";
        }
        sqlFiltro = sqlFiltro + idalbaranes[i];
        hayFiltro = true;
    }
    sqlFiltro = sqlFiltro + ")";
    if ( hayFiltro ) {
        thisForm.db_idalbaran.searchFilter = sqlFiltro;
    }
}

alepherp.DBRecordDlgDocumentosGestion.prototype.deabonoValueModified = function(albaran) {
    if ( bean.metadata.tableName == "albaranesprov" || bean.metadata.tableName == "albaranescli" ) {
        thisForm.db_idalbaranrect.dataEditable = bean.deabono.value;
        if ( !bean.deabono.value ) {
            bean.idalbaranrect.value = 0;
        }
    }
    if ( bean.metadata.tableName == "facturasprov" || bean.metadata.tableName == "facturascli" ) {
        thisForm.db_idfacturarect.dataEditable = bean.deabono.value;
        if ( !bean.deabono.value ) {
            bean.idfacturarect.value = 0;
        }
    }
    if ( !bean.deabono.value ) {
        thisForm.db_codrect.value = "";
    }
}

alepherp.DBRecordDlgDocumentosGestion.prototype.db_idalbaranrectAfterChoose = function(albaran) {
    if ( bean.metadata.tableName == "albaranesprov" || bean.metadata.tableName == "albaranescli" ) {
        if ( albaran.id.value > 0 ) {
            thisForm.db_codrect.value = albaran.codalbaran.value;
        }
    }
    var ret = AERPMessageBox.question("¿Desea utilizar y copiar los datos del albarán que acaba de seleccionar en este albarán de abono que está creando? Si contesta sí, se sobreescribirán todos sus datos.", AERPMessageBox.Yes | AERPMessageBox.No);
    if ( ret == AERPMessageBox.No ) {
        return;
    }
    bean.copyValues(albaran, "tasaconv", "coddivisa", "codpais", "provincia", "ciudad", "codpostal", "direccion", "nombredirtercero", "iddirtercero", "idtercero", "cifnif", "nombre", "idubicacion", "idtarifa");
    var tableOriginal;
    if ( bean.metadata.tableName == "albaranesprov" ) {
        tableOriginal = "prov";
    } else if (bean.metadata.tableName == "albaranescli") {
        tableOriginal = "cli";
    } else {
        return;
    }
    for (var i = 0 ; i < albaran["lineasarticulosalbaranes" + tableOriginal].items.length ;i++) {
        var linea = bean["lineasarticulosalbaranes" + tableOriginal].newChild();
        linea.copyValues(albaran["lineasarticulosalbaranes" + tableOriginal].items[i]);
    }
    for (var i = 0 ; i < albaran["lineasserviciosalbaranes" + tableOriginal].items.length ;i++) {
        var linea = bean["lineasserviciosalbaranes" + tableOriginal].newChild();
        linea.copyValues(albaran["lineasserviciosalbaranes" + tableOriginal].items[i]);
    }    
}

alepherp.DBRecordDlgDocumentosGestion.prototype.db_idfacturarectAfterChoose = function(factura) {
    if ( bean.metadata.tableName == "facturasprov" || bean.metadata.tableName == "facturascli" ) {
        if ( factura.id.value > 0 ) {
            thisForm.db_codrect.value = factura.codfactura.value;
        }
    }
    var ret = AERPMessageBox.question("¿Desea utilizar y copiar los datos de la factura que acaba de seleccionar en esta factura de abono que está creando? Si contesta sí, se sobreescribirán todos sus datos.", AERPMessageBox.Yes | AERPMessageBox.No);
    if ( ret == AERPMessageBox.No ) {
        return;
    }
    bean.copyValues(factura, "tipooperacion", "nombre", "cifnif", "idtercero", "iddirtercero", "nombredirtercero", "coddivisa", "idubicacion", "tasaconv", "codpais", "provincia", "ciudad", "codpostal", "direccion", "idtarifa");
    var tableOriginal;
    if ( bean.metadata.tableName == "facturasprov" ) {
        tableOriginal = "prov";
    } else if (bean.metadata.tableName == "facturascli") {
        tableOriginal = "cli";
    } else {
        return;
    }
    for (var i = 0 ; i < factura["lineasarticulosfacturas" + tableOriginal].items.length ;i++) {
        var linea = bean["lineasarticulosfacturas" + tableOriginal].newChild();
        linea.copyValues(factura["lineasarticulosfacturas" + tableOriginal].items[i]);
    }
    for (var i = 0 ; i < factura["lineasserviciosfacturas" + tableOriginal].items.length ;i++) {
        var linea = bean["lineasserviciosfacturas" + tableOriginal].newChild();
        linea.copyValues(factura["lineasserviciosfacturas" + tableOriginal].items[i]);
    }      
}

alepherp.DBRecordDlgDocumentosGestion.prototype.generarAsientoContable = function() {
    if ( !bean.nogenerarasiento.value && !bean.seriesfacturacion.father.ignoracontabilidad.value ) {
        bean.aerpCalcularImpuestos.call();
        bean.aerpGenerarAsiento.call();
    } else {
        var asiento = bean.co_asientos.brother;
        if ( asiento != null ) {
            asiento.dbState = BaseBean.TO_BE_DELETED;
            asiento.touch();
        }    
    }
}
