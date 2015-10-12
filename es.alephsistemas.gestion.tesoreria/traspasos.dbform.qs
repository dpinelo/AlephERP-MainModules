Function.prototype.bind = function() { 
    var func = this;
    var thisObject = arguments[0];
    var args = Array.prototype.slice.call(arguments, 1);
    return function() {
        return func.apply(thisObject, args);
    }
}

function DBFormDlg (ui) {
    loadExtension("qt.core");
    loadExtension("qt.gui");
    this.ui = ui;
}

DBFormDlg.prototype.beforeDelete = function(bean) {
    var entradas = bean.getRelatedElementsByCategory("Traspasos");
    if ( entradas.length > 0 ) {
        var ret = AERPMessageBox.question("¿Desea borrar también las entradas de banco/cajas asociadas a los traspasos?", AERPMessageBox.Yes | AERPMessageBox.No);
        if ( ret == AERPMessageBox.No ) {
            return true;
        }
        for (var i = 0 ; i < entradas.length ; i++) {
            entradas[i].relatedBean.dbState = BaseBean.TO_BE_DELETED;
        }
    }
    return true;
}
