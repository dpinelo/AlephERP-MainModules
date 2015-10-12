Function.prototype.bind = function() { 
    var func = this;
    var thisObject = arguments[0];
    var args = Array.prototype.slice.call(arguments, 1);
    return function() {
        return func.apply(thisObject, args);
    }
}

function DBRecordDlg (ui) {
    this.ui = ui;
    if ( bean.dbState == BaseBean.UPDATE && thisForm.db_chooseDocumentoExterno.masterBean != null ) {
        this.db_chooseDocumentoExternoAfterChoose();
    }
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

DBRecordDlg.prototype.db_chooseDocumentoExternoAfterChoose = function() {
    thisForm.db_fecha.dataEditable = false;
    thisForm.db_numdocumento.dataEditable = false;
    thisForm.script_datosgeneralestercero.dataEditable = false;
    thisForm.db_importe.dataEditable = false;
    thisForm.db_texto.dataEditable = false;
}

DBRecordDlg.prototype.db_chooseDocumentoExternoAfterClear = function() {
    thisForm.db_fecha.dataEditable = true;
    thisForm.db_numdocumento.dataEditable = true;
    thisForm.script_datosgeneralestercero.dataEditable = false;
    thisForm.db_importe.dataEditable = true;
    thisForm.db_texto.dataEditable = true;
}

