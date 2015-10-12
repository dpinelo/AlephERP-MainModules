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

DBFormDlg.prototype.filterAcceptsRow = function(bean, beanPadre) {
    if ( beanPadre != undefined && beanPadre.metadata.tableName != "co_cuentas" && bean.metadata.tableName == "co_cuentas" && bean.dbState == BaseBean.UPDATE ) {
        if ( bean.idcuentapadre.value > 0 ) {
            return false;
        }
    }
    return true;
}

