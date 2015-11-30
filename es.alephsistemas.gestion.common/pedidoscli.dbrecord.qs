function DBRecordDlg (ui) {
    this.init(ui);
}

AERPLoadExtension("alepherp");
DBRecordDlg.prototype = new alepherp.DBRecordDlgDocumentosGestion();

