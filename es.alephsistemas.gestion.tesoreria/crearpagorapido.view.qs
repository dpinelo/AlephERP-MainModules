Function.prototype.bind = function() { 
    var func = this;
    var thisObject = arguments[0];
    var args = Array.prototype.slice.call(arguments, 1);
    return function() {
        return func.apply(thisObject, args);
    }
}

function ScriptDlg (ui) {
    loadExtension("qt.core");
    loadExtension("qt.gui");
    this.ui = ui;

    this.pbOk = this.ui.findChild("pbOk");
    this.pbCancel = this.ui.findChild("pbCancel");
    this.pbOk.clicked.connect(this, "pagoRapido");
    this.pbCancel.clicked.connect(this, "cerrar");
    thisForm.db_fecha.value = new Date();
    thisForm.db_formaspago['valueEdited(QVariant)'].connect(this, "checkFormasPago");
}

ScriptDlg.prototype.cerrar = function () {
    thisForm.userClickOk = false;
    thisForm.close();
}

ScriptDlg.prototype.checkFormasPago = function() {
    if ( thisForm.db_formaspago.currentIndex == -1 ) {
        return;
    }
    var formaPago = thisForm.db_formaspago.selectedBean();
    if ( formaPago != null ) {
        if ( !formaPago.fieldValue("movimientobancario") ) {
            thisForm.db_cuentasbanco.enabled = false;
        } else {
            thisForm.db_cuentasbanco.enabled = true;
        }
    }
}

ScriptDlg.prototype.pagoRapido = function() {
    if ( thisForm.db_formaspago.currentIndex == -1 ) {
        AERPMessageBox.information("Debe seleccionar una forma de pago");
        return;
    }
    if ( thisForm.importeMax < thisForm.db_importe.value ) {
        var ret = AERPMessageBox.question("El cobro que ha introducido excede al documento original. ¿Está seguro de querer continuar?", AERPMessageBox.Yes | AERPMessageBox.No);
        if ( ret == AERPMessageBox.No ) {
            return;
        }
    }
    
    var beanFormaPago = thisForm.db_formaspago.selectedBean();
    // Estas propiedades que pasamos aquí, podrán ser leídas desde el diálogo que invocó a éste.
    thisForm.idformapago = beanFormaPago.fieldValue("id");
    var beanCuentaBancaria = thisForm.db_cuentasbanco.selectedBean();
    if ( beanCuentaBancaria != null ) {
        thisForm.idcuentabanco = beanCuentaBancaria.fieldValue("id");
    }
    thisForm.importe = thisForm.db_importe.value;
    thisForm.fecha = thisForm.db_fecha.value;
    thisForm.comision = thisForm.db_comision.value;
    thisForm.userClickOk = true;
    thisForm.close();
}

