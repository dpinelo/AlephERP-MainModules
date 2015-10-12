function DBRecordDlg (ui) {
    this.ui = ui;
    
    this.ui.findChild("pbGenerarAsiento").clicked.connect(this, "generarAsientoContable");    
}

DBRecordDlg.prototype.validate = function() {
    return true;
}

DBRecordDlg.prototype.beforeSave = function() {
    bean.aerpGenerarMovimientosDinerarios.call();
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

DBRecordDlg.prototype.idcuentaorigenValueModified = function () {
    if ( bean.idcuentaorigen.value > 0 ) {
        bean.idcajaorigen.value = 0;
        bean.idtarjetaorigen.value = 0;
    }
}

DBRecordDlg.prototype.idcajaorigenValueModified = function() {
    if ( bean.idcajaorigen.value > 0 ) {
        bean.idcuentaorigen.value = 0;
        bean.idtarjetaorigen.value = 0;
    }
}

DBRecordDlg.prototype.idtarjetaorigenValueModified = function() {
    if ( bean.idtarjetaorigen.value > 0 ) {
        bean.idcuentaorigen.value = 0;
        bean.idcajaorigen.value = 0;
    }
}

DBRecordDlg.prototype.idcuentadestinoValueModified = function() {
    if ( bean.idcuentadestino.value > 0 ) {
        bean.idcajadestino.value = 0;
    }
}

DBRecordDlg.prototype.idcajadestinoValueModified = function() {
    if ( bean.idcajadestino.value > 0 ) {
        bean.idcuentadestino.value = 0;
    }
    bean.aerpGenerarMovimientosDinerarios.call();
}

DBRecordDlg.prototype.generarAsientoContable = function() {
    bean.aerpGenerarMovimientosDinerarios.call();
    if ( !bean.nogenerarasiento.value ) {
        bean.aerpGenerarAsientoTraspaso.call();
    } else {
        var asiento = bean.co_asientos.brother;
        if ( asiento != null ) {
            asiento.dbState = BaseBean.TO_BE_DELETED;
            asiento.touch();
        }    
    }
}
