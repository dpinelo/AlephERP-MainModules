function DBRecordDlg (ui) {
    this.init(ui);
}

// Aquí se produce la herencia del código compartido entre los documentos de gestión (pedidos, albaranes, facturas...)
AERPLoadExtension("alepherp");
DBRecordDlg.prototype = new alepherp.DBRecordDlgDocumentosGestion();
