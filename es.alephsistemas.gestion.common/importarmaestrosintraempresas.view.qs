Function.prototype.bind = function() {
  var func = this;
  var thisObject = arguments[0];
  var args = Array.prototype.slice.call(arguments, 1);
  return function() {
    return func.apply(thisObject, args);
  }
}

function ScriptDlg (ui) {
    this.ui = ui;
    this.idempresa = -1;
    this.idejercicio = "";
    this.idtienda = -1;
    this.idtiendaempenios = -1;

    // Valores que actualmente tiene seleccionado el usuario
    var idempresaorigen = AERPScriptCommon.envVar("idempresa");
   
    if ( idempresaorigen === undefined ) {
        this.idempresaorigen = -1;
    } else {
        this.idempresaorigen = idempresaorigen;
    }
    
    this.dbcrbEmpresaOrigen = this.ui.findChild("dbcrbEmpresaOrigen");
    this.dbcrbEmpresaDestino = this.ui.findChild("dbcrbEmpresaDestino");
    this.txtEmpresaOrigen = this.ui.findChild("txtEmpresaOrigen");
    this.txtEmpresaDestino = this.ui.findChild("txtEmpresaDestino");
    this.dbListView = this.ui.findChild("dbListView");
    
    // Obtenemos los bean de empresa y ejercicios que el usuario tiene actualmente
    if ( idempresaorigen != undefined ) {
        var beanEmpresa = AERPScriptCommon.bean("empresas", "id=" + idempresaorigen);
        if ( beanEmpresa !== undefined ) {
            this.txtEmpresaOrigen.text = beanEmpresa.fieldValue("nombre");
        }
    }
    
    var spread = AERPScriptCommon.openSpreadSheet("/home/david/src/alepherp/trunk/src/3rdparty/libxls/test/files/test2.xls", "xls");
    
    this.ui.pbAceptar.clicked.connect(this, "aceptar");
    this.ui.pbCancelar.clicked.connect(this, "cerrar");
}

ScriptDlg.prototype.cerrar = function()
{
    thisForm.close();
}

ScriptDlg.prototype.aceptar = function () 
{
    var metadatas = this.dbListView.checkedMetadatas;
    var orderedList = AERPScriptCommon.orderMetadatasForInsertUpdate(metadatas);
    var tableNames = new Array;
    for (var i = 0 ; i < orderedList.length ;i++) {
        tableNames[i] = orderedList[i].tableName;
    }
    if ( this.dbcrbEmpresaOrigen.selectedBean != null && this.dbcrbEmpresaDestino.selectedBean != null ) {
        var empresaDestino = this.dbcrbEmpresaDestino.selectedBean;
        var empresaOriden = this.dbcrbEmpresaOrigen.selectedBean;
        for (var i = 0 ; i < orderedList.length ; i++ ) {
            if ( orderedList[i].field("idempresa") != null ) {
                var beansOrigen = AERPScriptCommon.beans(orderedList[i].tableName, "idempresa = " + empresaOriden.id.value, orderedList[i].pkOrder);
                for (var j = 0 ; j < beansOrigen.length ; j++) {
                    var beanDest = AERPScriptCommon.createBean(orderedList[i].tableName);
                    AERPScriptCommon.addToTransaction(beanDest);
                    beanDest.copyValues(beansOrigen[j]);
                    beanDest.idempresa.setOverwriteValue(empresaDestino.id.value);
                    beanDest.deepCopyValues(beansOrigen[j], tableNames);
                    beanDest.save();
                    AERPScriptCommon.commit();
                }
            }
        }
    }
    thisForm.close();
}

/**
Esta función será llamada por dbcrbEmpresa automáticamente cuando el usuario escoga una empresa
*/
ScriptDlg.prototype.setEmpresaOrigen = function () 
{
    var beanEmpresa = this.dbcrbEmpresaOrigen.selectedBean;
    if ( beanEmpresa != null ) {
        this.txtEmpresaOrigen.text = beanEmpresa.fieldValue("nombre");
    }
}

ScriptDlg.prototype.setEmpresaDestino = function () 
{
    var beanEmpresa = this.dbcrbEmpresaDestino.selectedBean;
    if ( beanEmpresa != null ) {
        this.txtEmpresaDestino.text = beanEmpresa.fieldValue("nombre");
    }
}
