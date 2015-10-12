Function.prototype.bind = function() {
    var func = this;
    var thisObject = arguments[0];
    var args = Array.prototype.slice.call(arguments, 1);
    return function() {
         return func.apply(thisObject, args);
    }
}

function DBFormDlg (ui) {
    this.ui = ui;
}

DBFormDlg.prototype.beforeDelete = function ()
{
    var beanToBeDeleted = thisForm.dbItemView.selectedBean();
    if ( beanToBeDeleted != undefined ) {
        if ( beanToBeDeleted.codigointernoservicio.value != "" && beanToBeDeleted.codigointernoservicio.value != undefined && beanToBeDeleted.codigointernoservicio.value != null ) {
            AERPMessageBox.information("Este es un servicio especial. No puede borrarse.");
            return false;
        }
    }
    return true;
}
