function ScriptDlg (ui) {
    this.ui = ui;
 
    this.ui.findChild("pbExportar").clicked.connect(this, "exportar");
    this.ui.findChild("pbCancel").clicked.connect(this, "cancelar");
}

ScriptDlg.prototype.cancelar = function() {
        thisForm.close();
}

ScriptDlg.prototype.exportar = function() {
}