function DBRecordDlg (ui) {
    loadExtension("qt.core");
    loadExtension("qt.gui");
    this.ui = ui;
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

DBRecordDlg.prototype.asignarCentroCoste = function() {
    var beanSubcentro = thisForm.db_idsubcentro.selectedBean;
    if ( beanSubcentro != null ) {
        bean.setFieldValue("idcentro", beanSubcentro.fieldValue("idcentrocoste"));    
        thisForm.db_nombrecentro.refresh();
        thisForm.db_nombresubcentro.refresh();        
    }
}

