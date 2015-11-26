function DBRecordDlg (ui) {
    this.ui = ui;
}

DBRecordDlg.prototype.validate = function() {
    if ( thisForm.db_password.userModified && thisForm.db_password.value != thisForm.db_password_2.value ) {
        AERPMessageBox.warning("Las contraseñas no coinciden");
        return false;
    }
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
