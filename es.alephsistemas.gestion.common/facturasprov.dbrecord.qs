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
    bean.aerpTest.call("Hola");
}

// Herencia de los objetos de gestión
AERPLoadExtension("alepherp");
DBRecordDlg.prototype = new alepherp.DBRecordDlgDocumentosGestion();

