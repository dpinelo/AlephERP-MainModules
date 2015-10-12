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
    if(bean.dbState  == BaseBean.UPDATE) {
        thisForm.db_numero.dataEditable = false;
        thisForm.db_fecha.dataEditable = false;
    } 
}

DBRecordDlg.prototype.validate = function() {
    var descuadre = bean.descuadre.value;
    if (  descuadre != 0) {
         AERPMessageBox.warning("El asiento está descuadrado. Debe corregirlo para poder guardarlo.");
       return false;
    }
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

DBRecordDlg.prototype.db_documento_facturasprovText = function() {
    if ( thisForm.db_documento_facturasprov.bean != null ) {
        return "<strong>" + thisForm.db_documento_facturasprov.bean.metadata.alias + "</strong>: <a href='" + thisForm.db_documento_facturasprov.field.value + "'>" + thisForm.db_documento_facturasprov.field.displayValue + "</a>";
    }
}

DBRecordDlg.prototype.db_documento_facturascliText = function() {
    if ( thisForm.db_documento_facturascli.bean != null ) {
        return "<strong>" + thisForm.db_documento_facturascli.bean.metadata.alias + "</strong>: <a href='" + thisForm.db_documento_facturascli.field.value + "'>" + thisForm.db_documento_facturascli.field.displayValue + "</a>";
    }
}
