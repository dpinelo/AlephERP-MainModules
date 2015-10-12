Function.prototype.bind = function() {
    var func = this;
    var thisObject = arguments[0];
    var args = Array.prototype.slice.call(arguments, 1);
    return function() {
        return func.apply(thisObject, args);
    }
}

function DBReportRunDlg (ui) {
    this.ui = ui;
}

DBReportRunDlg.prototype.validate = function() {
    return true;
}

DBReportRunDlg.prototype.beforeRunReport = function() {
    // thisForm.setParameterValue("P_ID_EMPRESA", AERPScriptCommon.envVar("idempresa"));
    return true;
}


