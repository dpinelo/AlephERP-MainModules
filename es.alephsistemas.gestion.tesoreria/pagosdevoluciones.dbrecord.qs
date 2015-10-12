function DBRecordDlg (ui) {
    this.ui = ui;
    this.gbComisiones = this.ui.findChild("gbComisiones");
    
    if ( bean.dbState == BaseBean.UPDATE ) {
        this.tipoValueModified();
    } else {
        this.gbComisiones.visible = false;
    }
    
    if ( thisForm.openType != AlephERP.ReadOnly ) {
        this.ui.findChild("pbGenerarAsiento").clicked.connect(this, "generarAsientoContable");
    }
    
}

DBRecordDlg.prototype.validate = function() {
    return true;
}

DBRecordDlg.prototype.beforeSave = function() {
    bean.aerpCrearOActualizarMovimientoDinerario.call();
    return true;
}

DBRecordDlg.prototype.beanSaved = function() {
    return;
}

DBRecordDlg.prototype.beforeNavigate = function() {
    return true;
}

DBRecordDlg.prototype.afterNavigate = function() {
    return;
}

DBRecordDlg.prototype.tipoValueModified = function() {
    if ( bean.fieldValue("tipo") == "Devolución" ) {
        this.gbComisiones.visible = true;
    } else {
        this.gbComisiones.visible = false;
    }
}

DBRecordDlg.prototype.generarAsientoContable = function() {
    if ( !bean.nogenerarasiento.value ) {
        bean.aerpGenerarAsiento.call();
    }
}
