Function.prototype.bind = function() { 
    var func = this;
    var thisObject = arguments[0];
    var args = Array.prototype.slice.call(arguments, 1);
    return function() {
        return func.apply(thisObject, args);
    }
}

function DBRecordDlg (ui) {
    this.ui = ui;
    
    if ( bean.idsubcuentaamortizacion.value > 0 ) {
        this.ui.findChild("pbCrearSubcuentaAmortizacion").visible = false;
    }
    if ( bean.idsubcuenta.value > 0 ) {
        this.ui.findChild("pbCrearSubcuenta").visible = false;
    }
    this.ui.findChild("pbCrearSubcuenta").clicked.connect(this, "crearCuentaActivo");
    this.ui.findChild("pbCrearSubcuentaAmortizacion").clicked.connect(this, "crearCuentaAmortizacion");
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

DBRecordDlg.prototype.idsubcuentaValueModified = function() {
    this.ui.findChild("pbCrearSubcuenta").visible = bean.idsubcuenta.value > 0;
}

DBRecordDlg.prototype.idsubcuentaamortizacionValueModified = function() {
    this.ui.findChild("pbCrearSubcuentaAmortizacion").visible = bean.idsubcuentaamortizacion.value > 0;
}

DBRecordDlg.prototype.crearCuentaActivo = function() {
    var cuenta = AERPScriptCommon.chooseRecordFromTable("co_cuentas", "codcuenta like '2%'", "codcuenta", "Seleccione la cuenta contable");
    if ( cuenta != null ) {
        var subcuenta = cuenta.co_subcuentas.newChild();
        subcuenta.descripcion.value = bean.nombre.value;
        bean.co_subcuentas_activo.brother = subcuenta;
    }
}

DBRecordDlg.prototype.crearCuentaAmortizacion = function() {
    var cuenta = AERPScriptCommon.chooseRecordFromTable("co_cuentas", "codcuenta like '28%'", "codcuenta", "Seleccione la cuenta contable");
    if ( cuenta != null ) {
        var subcuenta = cuenta.co_subcuentas.newChild();
        subcuenta.descripcion.value = "AMORTIZACIÓN " + bean.nombre.value;
        bean.co_subcuentas_amortizacion.brother = subcuenta;
    }
}
