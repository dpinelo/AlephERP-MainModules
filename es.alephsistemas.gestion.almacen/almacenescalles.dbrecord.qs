function DBRecordDlg (ui) {
    this.ui = ui;
    
    this.ui.findChild("pbCrearUbicaciones").clicked.connect(this, "crearUbicaciones");
}

DBRecordDlg.prototype.validate = function() {
    return true;
}

DBRecordDlg.prototype.beforeSave = function() {
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

DBRecordDlg.prototype.crearUbicaciones = function() {
    var desde = AERPScriptCommon.getInt("Indique desde qué número se crearán las ubicaciones", 0);
    if ( desde == 0 ) {
        return;
    }
    var hasta = AERPScriptCommon.getInt("Indique hasta qué número se crearán las ubicaciones", 0);
    if ( hasta == 0 ) {
        return;
    }
    var prefijo = AERPScriptCommon.getText("Indique el prefijo a utilizar");
    for (var i = desde ; i < hasta ; i++ ) {
        var ubicacion = bean.almacenesubicaciones.newChild();
        //ubicacion.nombre = prefijo AERPScriptCommon.stringRightJustified("" + prefijo + i
    }
}