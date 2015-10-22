function DBRecordDlg(ui) {
    this.ui = ui;
    this.calculating = false;

    var beanEmpresaActual = empresaActual();
    this.pbMarcarPagada = this.ui.findChild("pbMarcarPagada");        
    this.tbCostes.visible = beanEmpresaActual.contabilidadcostes.value;
    this.ui.findChild("tabCostes").enabled = beanEmpresaActual.contabilidadcostes.value;
    this.pbAgregarMultiplesCentrosCoste = this.ui.findChild("pbAgregarMultiplesCentrosCoste");
    if ( beanEmpresaActual.fieldValue("contintegrada") == false ) {
        this.ui.findChild("tabContabilidad").enabled = false;
    } else {
        this.ui.findChild("pbGenerarAsiento").clicked.connect(this, "generarAsientoContable");
    }
    this.pbAgregarMultiplesCentrosCoste.clicked.connect(this, "agregarMultiplesCentrosCoste"); 
    this.pbMarcarPagada.clicked.connect(this, "marcarPagada");                     
}

DBRecordDlg.prototype.validate = function() {
    var beanEmpresaActual = empresaActual();    
    if ( beanEmpresaActual.contabilidadcostes.value == true ) {
        var lineasCostes = bean.relationChildsCount("rrhh_nominasdistribucioncostes");
        if ( lineasCostes == 0 ) {
            var ret = AERPMessageBox.question("No ha introducido ninguna distribución de costes. ¿Desea guardar sin asignar costes?", AERPMessageBox.Yes | AERPMessageBox.No);
            if ( ret == AERPMessageBox.No ) {
                return false;
            }
        } else {
            // Se comprueba que los cálculos de costes coinciden con el neto.
            if ( !AERPScriptCommon.equalsWithAllowedError(bean.totalcostesdistribuidos.value , bean.apercibir.value, 0.5) ) {
                var ret = AERPMessageBox.question("Los costes imputados no coinciden con el total a percibir en nómina. Esto podría desvirtuar la contabilidad de costes. ¿Está seguro de querer continuar?",
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
    if ( !bean.nogenerarasiento.value ) {
        bean.aerpGenerarAsiento.call();
    }
    return true;
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

DBRecordDlg.prototype.marcarPagada = function() {
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

