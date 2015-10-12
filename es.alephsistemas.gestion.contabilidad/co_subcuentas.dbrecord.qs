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
    if (bean.dbState  == BaseBean.UPDATE) {
        thisForm.db_codsubcuenta.dataEditable = false;
    } 
}

DBRecordDlg.prototype.validate = function() {
    var codCuenta = bean.co_cuentas.father.codcuenta.value;
    var codSubcuenta = bean.codsubcuenta.value;
    if ( (4 + bean.ejercicios.father.longsubcuenta.value) != codSubcuenta.length ) {
         AERPMessageBox.warning("El código de la subcuenta debe tener la longitud establecida para el ejercicio actual: " + (4 + bean.ejercicios.father.longsubcuenta.value) + " dígitos.");
       return false;
    }
    if ( codCuenta.substring(0, 3) != codSubcuenta.substring(0, codCuenta.length-1) ) {
       AERPMessageBox.warning("El código de la Subcuenta debe tener como prefijo el código de la cuenta." );
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

DBRecordDlg.prototype.enlaceADocumento = function() {
    return;
}

