function DBRecordDlg (ui) {
    this.init(ui);
    //thisForm.db_servicios_referencia.relationFilter = "idempresa=" + idempresaActual();
}

AERPLoadExtension("alepherp");
DBRecordDlg.prototype = new alepherp.DBRecordDlgLineasServiciosDocumentosGestion();
