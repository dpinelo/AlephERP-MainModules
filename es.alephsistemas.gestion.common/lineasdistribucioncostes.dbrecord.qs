Function.prototype.bind = function() { 
    var func = this;
    var thisObject = arguments[0];
    var args = Array.prototype.slice.call(arguments, 1);
    return function() {
        return func.apply(thisObject, args);
    }
}

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

DBRecordDlg.prototype.idsubcentroSelected = function() {
    var beanSubcentro = thisForm.db_idsubcentro.selectedBean;
    if ( beanSubcentro != null ) {
        bean.setFieldValue("descripcionsubcentro", beanSubcentro.fieldValue("nombre"));
        var beanCentro = beanSubcentro.father("centroscoste");
        bean.setFieldValue("descripcioncentro", beanCentro.fieldValue("nombre"));
        bean.setFieldValue("idcentro", beanCentro.fieldValue("id"));
    }
}

