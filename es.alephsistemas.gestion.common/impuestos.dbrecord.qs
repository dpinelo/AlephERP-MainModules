function DBRecordDlg (ui) {
    loadExtension("qt.core");
    loadExtension("qt.gui");
    this.ui = ui;

    // Obtenemos y guardamos los objetos más habituales de la UI
    this.tbDatos = this.ui.findChild("tbDatos");
    this.tbContabilidad = this.ui.findChild("tbContabilidad");
    this.swFichas = this.ui.findChild("swFichas");

    this.tbDatos.checked = true;
    this.swFichas.setCurrentWidget(this.ui.findChild("pageDatosGenerales"));

    this.tbDatos.clicked.connect(this, "showPage");
    this.tbContabilidad.clicked.connect(this, "showPage");
}

DBRecordDlg.prototype.showPage = function() {
    if ( this.tbDatos.checked ) {
        this.swFichas.setCurrentWidget(this.ui.findChild("pageDatosGenerales"));
    } else if ( this.tbContabilidad.checked ) {
        this.swFichas.setCurrentWidget(this.ui.findChild("pageContabilidad"));
    }
}

