function DBRecordDlg (ui) {
    loadExtension("qt.core");
    loadExtension("qt.gui");
    this.ui = ui;
}

DBRecordDlg.prototype.validate = function() {
    return true;
}

DBRecordDlg.prototype.beforeSave = function() {
    if ( bean.tipo.value == "Entrada" && bean.importe.value < 0 ) {
        bean.importe.value = bean.importe.value * -1;
    } else if (bean.tipo.value == "Salida" && bean.importe.value > 0 ) {
        bean.importe.value = bean.importe.value * -1;
    }    
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

DBRecordDlg.prototype.tipoValueModified = function() {
    if ( bean.tipo.value == "Entrada" && bean.importe.value < 0 ) {
        bean.importe.value = bean.importe.value * -1;
    } else if (bean.tipo.value == "Salida" && bean.importe.value > 0 ) {
        bean.importe.value = bean.importe.value * -1;
    }
}
