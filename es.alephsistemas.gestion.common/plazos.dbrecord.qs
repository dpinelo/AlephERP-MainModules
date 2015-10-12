Function.prototype.bind = function() { 
    var func = this;
    var thisObject = arguments[0];
    var args = Array.prototype.slice.call(arguments, 1);
    return function() {
        return func.apply(thisObject, args);
    }
}

function DBRecordDlg (ui) {
    loadExtension("qt.core");
    loadExtension("qt.gui");
    this.ui = ui;
    this.cargodiafijomesValueModified();
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

DBRecordDlg.prototype.cargodiafijomesValueModified = function() {
    if ( bean.cargodiafijomes.value == true ) {
        thisForm.db_dias.dataEditable = false;
        thisForm.db_diames.dataEditable = true;
    } else {
        thisForm.db_dias.dataEditable = true;
        thisForm.db_diames.dataEditable = false;
    }
}

