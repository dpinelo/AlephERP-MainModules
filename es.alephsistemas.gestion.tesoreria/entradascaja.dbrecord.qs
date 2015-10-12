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

DBRecordDlg.prototype.calculasaldos = function()
{
    var tipo = this.getTipo();
    var sql = "select saldofinal from entradascaja where idcaja = " + bean.idcaja.value + 
              " and fecha <= " + bean.sqlFieldValue("fecha") + " order by id desc limit 1";
    var qry = new PERPSqlQuery;
    var saldoInicial = 0;
    qry.prepare(sql);
    res = qry.exec();
    if (res && qry.first()){
        saldoInicial = qry.value(0);
    }
    bean.setFieldValue("saldoinicial", saldoInicial);
}

DBRecordDlg.prototype.recalculaCaja = function()
{
    var sqlAct = "select recalcularcaja('"+idejercicioActual()+"', "+this.idtienda+")";
    var qryAct = new PERPSqlQuery(thisForm);
    qryAct.prepare(sqlAct);
    var resAct = qryAct.exec();
    if ( resAct == true ) {
        debug("Caja actualizada");
    } else {
        debug("Algo ha ido mal actualizando la caja");
    }
}

