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

DBFormDlg.prototype.beforeDelete = function(bean) {
    var entradas = new Array;
    if ( bean.metadata.tableName == "efectospago" ) {
        for (var i = 0 ; i < bean.pagosdevoluciones.items.length ; i++) {
            var entradasbanco = bean.pagosdevoluciones.items[i].getRelatedElementsByRelatedTableName("entradasbanco");
            var entradascaja = bean.pagosdevoluciones.items[i].getRelatedElementsByRelatedTableName("entradascaja");
            for ( var j = 0 ; j < entradasbanco.length ; j++ ) {
                entradas[entradas.length] = entradasbanco[j];
            }
            for ( var j = 0 ; j < entradascaja.length ; j++ ) {
                entradas[entradas.length] = entradascaja[j];
            }
        }
    } else if ( bean.metadata.tableName == "efectoscobro" ) {
        for (var i = 0 ; i < bean.cobrosdevoluciones.items.length ; i++) {
            var entradasbanco = bean.cobrosdevoluciones.items[i].getRelatedElementsByRelatedTableName("entradasbanco");
            var entradascaja = bean.cobrosdevoluciones.items[i].getRelatedElementsByRelatedTableName("entradascaja");
            for ( var j = 0 ; j < entradasbanco.length ; j++ ) {
                entradas[entradas.length] = entradasbanco[j];
            }
            for ( var j = 0 ; j < entradascaja.length ; j++ ) {
                entradas[entradas.length] = entradascaja[j];
            }
        }
    }
    /*
    var ret = AERPMessageBox.question("¿Está seguro de querer borrar este efecto?", AERPMessageBox.Yes | AERPMessageBox.No);
    if ( ret == AERPMessageBox.No ) {
        return false;
    }
    */
    if ( entradas.length > 0 ) {
        var ret = AERPMessageBox.question("Este efecto de pago/cobro tiene asociados movimientos monetarios reales (es decir, pagos realmente realizados, o cobros realmente realizados y que están anotados en las cajas y/o bancos). \
        <br/>¿Desea borrar también las entradas de banco/cajas asociadas a los movimientos de pago/cobro de este efecto? Tenga en cuenta que el estado de las cajas y los bancos en los que estuviean apuntados esos pagos/cobros cambiará.", AERPMessageBox.Yes | AERPMessageBox.No);
        if ( ret == AERPMessageBox.No ) {
            return true;
        }
        for (var i = 0 ; i < entradas.length ; i++) {
            entradas[i].relatedBean.dbState = BaseBean.TO_BE_DELETED;
        }
    }
    return true;
}

