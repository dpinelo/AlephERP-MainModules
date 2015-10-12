({

init: function(ui) {
    this.ui = ui;

    // Obtenemos y guardamos los objetos más habituales de la UI
    this.tbDatos = this.ui.findChild("tbDatos");
    this.tbLineas = this.ui.findChild("tbLineas");
    this.tbObservaciones = this.ui.findChild("tbObservaciones");
    this.tbEfectos = this.ui.findChild("tbEfectos");    
    this.swFichas = this.ui.findChild("swFichas");

    this.swFichas.setCurrentWidget(this.ui.findChild("pageDatos"));
    this.tbDatos.checked = true;

    this.tbDatos.clicked.connect(this, "showPage");
    this.tbLineas.clicked.connect(this, "showPage");
    this.tbObservaciones.clicked.connect(this, "showPage");
    this.tbEfectos.clicked.connect(this, "showPage");

    if ( bean.metadata.tableName == "facturasprov" || bean.metadata.tableName == "facturascli" ) {
        var beanEmpresaActual = empresaActual();
        this.tbContabilidad = this.ui.findChild("tbContabilidad");
        this.tbCostes = this.ui.findChild("tbCostes");           
        this.pbMarcarPagada = this.ui.findChild("pbMarcarPagada");        
        this.tbCostes.visible = beanEmpresaActual.contabilidadcostes.value;
        this.pbAgregarMultiplesCentrosCoste = this.ui.findChild("pbAgregarMultiplesCentrosCoste");
        this.tbContabilidad.clicked.connect(this, "showPage");
        this.tbCostes.clicked.connect(this, "showPage");
        if ( beanEmpresaActual.fieldValue("contintegrada") == false ) {
            this.tbContabilidad.enabled = false;
        }
        this.pbAgregarMultiplesCentrosCoste.clicked.connect(this, "agregarMultiplesCentrosCoste"); 
        this.pbMarcarPagada.clicked.connect(this, "marcarPagada");                     
    }
    if ( bean.fieldValue("ptepago") == false ) {
        this.pbMarcarPagada.visible = false;
    }

    if ( bean.dbState == BaseBean.INSERT ) {
        thisForm.db_iddirtercero.enabled = false;
    } else {
        thisForm.db_iddirtercero.beanSearchList = bean.terceros.father;
        this.setColorForIVAField();
    }
},


showPage: function() {
    if ( this.tbDatos.checked ) {
        this.swFichas.setCurrentWidget(this.ui.findChild("pageDatos"));
    } else if ( this.tbLineas.checked ) {
        this.swFichas.setCurrentWidget(this.ui.findChild("pageLineas"));
    } else if ( this.tbObservaciones.checked ) {
        this.swFichas.setCurrentWidget(this.ui.findChild("pageObservaciones"));
    } else if ( (bean.metadata.tableName == "facturasprov" || bean.metadata.tableName == "facturascli") && this.tbContabilidad.checked ) {
        this.swFichas.setCurrentWidget(this.ui.findChild("pageContabilidad"));
    } else if ( (bean.metadata.tableName == "facturasprov" || bean.metadata.tableName == "facturascli") && this.tbCostes.checked ) {
        this.swFichas.setCurrentWidget(this.ui.findChild("pageCostes"));
    } else if ( this.tbEfectos.checked ) {
        this.swFichas.setCurrentWidget(this.ui.findChild("pageEfectos"));
        if ( bean.metadata.tableName == "facturasprov" ) {
            this.efectospagoautomaticosValueModified();
        } else if ( bean.metadata.tableName == "facturascli" ) {
            this.efectoscobroautomaticosValueModified();
        }
    }
},

validate: function() {
    var beanEmpresaActual = empresaActual();    
        if ( beanEmpresaActual.contabilidadcostes.value == true && (bean.metadata.tableName == "facturasprov") ) {
            var lineasCostes = bean.relationChildsCount("lineasdistribucioncostes" + bean.metadata.tableName);
            if ( lineasCostes == 0 ) {
                var ret = AERPMessageBox.question(thisForm, "No ha introducido ninguna distribución de costes. ¿Desea guardar sin asignar costes?",
                    AERPMessageBox.StandardButtons(AERPMessageBox.Yes, AERPMessageBox.No));
            if ( ret == AERPMessageBox.No ) {
                return false;
            }
        }
        // Se comprueba que los cálculos de costes coinciden con el neto.
        if ( !AERPScriptCommon.equalsWithAllowedError(bean.totalcostesdistribuidos.value, bean.neto.value, 0.5) ) {
            var ret = AERPMessageBox.question(thisForm, "Los costes imputados no coinciden con la base imponible de la factura. Esto podría desvirtuar la contabilidad de costes. ¿Está seguro de querer continuar?",
            AERPMessageBox.StandardButtons(AERPMessageBox.Yes, AERPMessageBox.No));
            if ( ret == AERPMessageBox.No ) {
                return false;
            }            
        }
    }
    return true;        
},

terceroWasSelected: function() {
    var beanTercero = thisForm.db_idtercero.selectedBean;
    if ( beanTercero != null ) {
        if ( bean.idserie.value == 0 ) {
            bean.idserie.value = beanTercero.idserie.value;
        }
        if ( bean.fieldValue("idplanpago") == 0 ) {
            bean.idplanpago.value = beanTercero.idplanpago.value;
        }
        bean.iddirtercero.value = 0;
        bean.nombredirtercero.value = "";
        thisForm.db_iddirtercero.beanSearchList = beanTercero;
    }
},

idterceroValueModified: function() {
    thisForm.db_iddirtercero.enabled = true;
},

updateTasaConv: function() {
    var beanDivisa = thisForm.db_coddivisa.selectedBean;
    if ( beanDivisa != null ) {
        bean.tasaconv.value = beanDivisa.tasaconv.value;
    }
},

asignarCostes: function() {
    var lineasCostes = bean.relationChilds("lineasdistribucioncostes" + bean.metadata.tableName);
    if ( lineasCostes.length > 0 ) {
        var ret = AERPMessageBox.question(this, "AlephERP", "Al escoger una nueva distribución de costes, se borrará la existente. ¿Desea continuar?",
            AERPMessageBox.StandardButtons(AERPMessageBox.Yes, AERPMessageBox.No));
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
},

efectoscobroautomaticosValueModified: function() {
    if ( bean.efectoscobroautomaticos.modified ) {
        if ( bean.efectoscobroautomaticos.value == true ) {
            thisForm.db_efectoscobro.visibleButtons = DBDetailView.ViewButton;
            this.pbMarcarPagada.visible = false;
            bean.aerpGenerarEfectos.call();
        } else {
            thisForm.db_efectoscobro.visibleButtons = DBDetailView.InsertButton | DBDetailView.UpdateButton | DBDetailView.DeleteButton | 
            DBDetailView.ViewButton | DBDetailView.InsertExistingButton | DBDetailView.RemoveExistingButton;
            this.pbMarcarPagada.visible = true;
        }
    }
},

efectospagoautomaticosValueModified: function() {
    if ( bean.efectospagoautomaticos.modified ) {
        if ( bean.efectospagoautomaticos.value == true ) {
            thisForm.db_efectospago.visibleButtons = DBDetailView.ViewButton;
            this.pbMarcarPagada.visible = false;
            bean.aerpGenerarEfectos.call();
        } else {
            thisForm.db_efectospago.visibleButtons = DBDetailView.InsertButton | DBDetailView.UpdateButton | DBDetailView.DeleteButton | 
            DBDetailView.ViewButton | DBDetailView.InsertExistingButton | DBDetailView.RemoveExistingButton;
            this.pbMarcarPagada.visible = true;
        }
    }
},

marcarPagada: function() {
    if ( bean.modified ) {
        var ret = AERPMessageBox.question(this, "Para marcar la factura como pagada, debe guardarse primero. ¿Desea guardarla?",
                AERPMessageBox.StandardButtons(AERPMessageBox.Yes, AERPMessageBox.No));
        if ( ret == AERPMessageBox.No ) {
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
},

idserieValueModified: function() {
    this.setColorForIVAField();
},

idplanpagoValueModified: function() {
    bean.aerpGenerarEfectos.call();
},

setColorForIVAField: function() {
    // Cuando se agrega una serie de facturación que está exenta de IVA, se marcan los campos de IVA con un color especial
    // para destacar al usuario que en ellos no debe de haber valores.
    if ( bean.seriesfacturacion.father.tipoiva.value != "Sujeta a I.V.A." ) {
        thisForm.db_totaliva.styleSheet = "background:#FFF395";
    } else {
        thisForm.db_totaliva.styleSheet = "background:#FFFFFF";
    }
},

agregarMultiplesCentrosCoste: function() {
    var dlg = new DBDialog;
    dlg.type = "script";
    dlg.uiName = "facturasprovagregarsubcentroscoste.view.ui";
    dlg.qsName = "facturasprovagregarsubcentroscoste.view.qs";
    dlg.addPropertyToThisForm("beanFactura", bean);
    dlg.show();
},

lineasserviciosfacturasprovModifiedChild: function() {
    bean.aerpCalcularImpuestos.call();
},

lineasarticulosfacturasprovModifiedChild: function() {
    bean.aerpCalcularImpuestos.call();
},

lineasserviciosfacturascliModifiedChild: function() {
    bean.aerpCalcularImpuestos.call();
},

lineasarticulosfacturascliModifiedChild: function() {
    bean.aerpCalcularImpuestos.call();
}

})
