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
    
    var parentType = thisForm.parentType();
    if ( parentType == "DBDetailView" ) {
        thisForm.db_idcentrocoste.visible = false;
        thisForm.db_centroscoste_nombre.visible = false;
        thisForm.db_idcentro.visible = false;
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
