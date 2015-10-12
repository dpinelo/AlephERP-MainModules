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
        thisForm.db_codcuenta.dataEditable = false;
    } 
}

DBRecordDlg.prototype.validate = function() {
    var codSubgrupo = bean.co_subgrupos.father.codsubgrupo.value;;
    var codCuenta= bean.codcuenta.value;
    
    if (  codSubgrupo != codCuenta.substring(0, codSubgrupo.length) ) {
       AERPMessageBox.warning("El código dela cuenta debe tener como prefijo el código del subgrupo.");
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