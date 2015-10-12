Function.prototype.bind = function() { 
    var func = this;
    var thisObject = arguments[0];
    var args = Array.prototype.slice.call(arguments, 1);
    return function() {
        return func.apply(thisObject, args);
    }
}

function DBRecordDlg (ui) {
    this.init(ui);
    //thisForm.db_servicios_referencia.relationFilter = "idempresa=" + idempresaActual();
}

AERPLoadExtension("alepherp");
DBRecordDlg.prototype = new alepherp.DBRecordDlgLineasDocumentosGestion();
