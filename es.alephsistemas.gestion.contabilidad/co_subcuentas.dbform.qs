function DBFormDlg (ui) {
    AERPLoadExtension("qt.core");
    AERPLoadExtension("qt.gui");
    
    this.ui = ui;
    var boton = thisForm.createPushButton(10, "Recalcular saldos", "Recalcular Saldos", 
                                          ":/actions/actions/reload.png", "recalcularSaldos");
}

DBFormDlg.prototype.recalcularSaldos = function() {
    var subcuentas = AERPScriptCommon.beans("co_subcuentas", "idejercicio=" + idejercicioActual(), "codsubcuenta ASC");
    AERPScriptCommon.showProgressDialog("Recalculando saldos...", subcuentas.length);
    for ( var i = 0 ; i < subcuentas.length ; i++ ) {
        AERPScriptCommon.sqlExecute("UPDATE co_subcuentas SET debe=suma.debe, haber=suma.haber, saldo=suma.debe-suma.haber FROM (SELECT sum(debe) as debe, sum(haber) as haber FROM co_partidas WHERE idsubcuenta=" + subcuentas[i].id.value + ") AS suma WHERE id=" + subcuentas[i].id.value);
        AERPScriptCommon.setValueProgressDialog(i);
    }
    AERPScriptCommon.closeProgressDialog();
    return;
}