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
    if ( thisForm.db_chooseDocumentoExterno.masterBean != null ) {
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

DBRecordDlg.prototype.estadoValueModified = function() {
    if ( bean.idformapagoprevista.value <= 0 ) {
        // Solicitemos al usuario la forma de pago
        var formaPago = AERPScriptCommon.chooseRecordFromComboBox("formaspago", "descripcion", "idempresa=" + AERPScriptCommon.envVar("idempresa"), "descripcion ASC", "Seleccione la forma de pago");
        if ( formaPago != null ) {
            bean.idformapagoprevista.value = formaPago.id.value;
        }
    }
    if ( bean.estado.value == "Pagado" || bean.estado.value == "Cobrado" ) {
        bean.aerpMarcarPagadoCobrado.call();
    }
}

DBRecordDlg.prototype.db_chooseDocumentoExternoAfterChoose = function(selectedBean) {
    if ( bean.metadata.tableName == "efectospago" ) {
        thisForm.db_numdocumentotercero.dataEditable = false;
    }
    thisForm.script_datosgeneralestercero.dataEditable = false;
    thisForm.db_texto.dataEditable = false;
}

DBRecordDlg.prototype.db_chooseDocumentoExternoAfterClear = function() {
    if ( bean.metadata.tableName == "efectospago" ) {
        thisForm.db_numdocumentotercero.dataEditable = true;
    }
    thisForm.script_datosgeneralestercero.dataEditable = false;
    thisForm.db_texto.dataEditable = true;
}

DBRecordDlg.prototype.deleteEntradas = function(childDeleted) {
    if ( childDeleted == null || childDeleted == undefined ) {
        return;
    }
    var entradas = new Array;
    var entradasbanco = childDeleted.getRelatedElementsByRelatedTableName("entradasbanco");
    var entradascaja = childDeleted.getRelatedElementsByRelatedTableName("entradascaja");
    for ( var j = 0 ; j < entradasbanco.length ; j++ ) {
        entradas[entradas.length] = entradasbanco[j];
    }
    for ( var j = 0 ; j < entradascaja.length ; j++ ) {
        entradas[entradas.length] = entradascaja[j];
    }
    if ( entradas.length > 0 ) {
        var ret = AERPMessageBox.question("¿Desea borrar también las entradas de banco/cajas asociadas a los movimientos de pago/cobro de este efecto? Este efecto de pago/cobro tiene introducido movimientos reales monetarios (es decir, pagos realmente realizados, o cobros realmente realizados), el estado de las cajas y los bancos en los que estuviean apuntados esos pagos/cobros cambiará. ¿Está seguro de querer borrarlos?", AERPMessageBox.Yes | AERPMessageBox.No);
        if ( ret == AERPMessageBox.No ) {
            return;
        }
        for (var i = 0 ; i < entradas.length ; i++) {
            entradas[i].relatedBean.dbState = BaseBean.TO_BE_DELETED;
        }
    }
}

DBRecordDlg.prototype.pagosdevolucionesDeleteChild = function(childDeleted) {
    this.deleteEntradas(childDeleted);
}

DBRecordDlg.prototype.cobrosdevolucionesDeleteChild = function(childDeleted) {
    this.deleteEntradas(childDeleted);
}

