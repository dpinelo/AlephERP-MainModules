Function.prototype.bind = function() { 
    var func = this;
    var thisObject = arguments[0];
    var args = Array.prototype.slice.call(arguments, 1);
    return function() {
        return func.apply(thisObject, args);
    }
}

function DBWizardDlg (ui) {
    this.ui = ui;
}

DBWizardDlg.prototype.validate = function() {
    return true;
}

DBWizardDlg.prototype.beforeSave = function() {
    return true;
}

DBWizardDlg.prototype.beanSaved = function() {
    return;
}

DBWizardDlg.prototype.validatePage = function(page) {
    return true;
}

DBWizardDlg.prototype.initializePage = function(page) {
    return true;
}

DBWizardDlg.prototype.cleanupPage = function(page) {
    return true;
}

DBWizardDlg.prototype.isComplete = function(page) {
    return true;
}
