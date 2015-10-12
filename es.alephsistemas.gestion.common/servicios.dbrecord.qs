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

    // Obtenemos y guardamos los objetos más habituales de la UI
    this.tbDatos = this.ui.findChild("tbDatos");
    this.tbContabilidad = this.ui.findChild("tbContabilidad");
    this.tbDatos.checked = true;

    this.tbDatos.clicked.connect(this, "showPage");
    this.tbContabilidad.clicked.connect(this, "showPage");

    var beanEmpresaActual = empresaActual();
    if ( beanEmpresaActual.fieldValue("contintegrada") == false ) {
        this.tbContabilidad.enabled = false;
    }
    var swFichas = this.ui.findChild("swFichas");
    swFichas.setCurrentWidget(this.ui.findChild("pageDatos"));
}

DBRecordDlg.prototype.showPage = function() {
    var swFichas = this.ui.findChild("swFichas");
    if ( this.tbDatos.checked ) {
        swFichas.setCurrentWidget(this.ui.findChild("pageDatos"));
    } else if ( this.tbContabilidad.checked ) {
        swFichas.setCurrentWidget(this.ui.findChild("pageContabilidad"));
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


