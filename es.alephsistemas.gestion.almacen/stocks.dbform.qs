function DBFormDlg (ui) {
    AERPLoadExtension("qt.gui");
    this.ui = ui;
    this.pbRecalcular = thisForm.createPushButton(4, "Recalcular Stocks", "Recalcular Stocks", "", "recalcularStocks");
    thisForm.visibleButtons = DBForm.ViewButton | DBForm.ExitButton;
}

DBFormDlg.prototype.recalcularStocks = function(bean) {
    AERPLoadExtension("alepherp.almacen");
    alepherp.almacen.recalcularStocks();
}

