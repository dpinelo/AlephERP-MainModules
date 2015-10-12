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
    this.idempresa = -1;
    this.idejercicio = "";

    // Valores que actualmente tiene seleccionado el usuario
    var idempresa = AERPScriptCommon.envVar("idempresa");
    var idejercicio = AERPScriptCommon.envVar("idejercicio");
   
    if ( idempresa === undefined ) {
        this.idempresa = -1;
    } else {
        this.idempresa = idempresa;
    }
    if ( idejercicio === undefined ) {
        this.idejercicio = -1;
    } else {
        this.idejercicio = idejercicio;
    }
    this.dbcrbEmpresa = this.ui.findChild("dbcrbEmpresa");
    this.dbcrbEjercicio = this.ui.findChild("dbcrbEjercicio");
    this.txtCodEjercicioFiscal = this.ui.findChild("txtCodEjercicioFiscal");
    this.txtNombreEjercicioFiscal = this.ui.findChild("txtNombreEjercicioFiscal");
    this.txtEmpresa = this.ui.findChild("txtEmpresa");
    
    // Obtenemos los bean de empresa y ejercicios que el usuario tiene actualmente
    if ( idempresa != undefined ) {
        var beanEmpresa = AERPScriptCommon.bean("empresas", "id=" + idempresa);
        if ( beanEmpresa !== undefined ) {
            this.txtEmpresa.text = beanEmpresa.fieldValue("nombre");
            this.dbcrbEjercicio.searchFilter = "idempresa=" + idempresa;
            this.dbcrbEmpresa.selectedBean = beanEmpresa;
        }
    }
    if ( idejercicio != undefined ) {
        var beanEjercicio = AERPScriptCommon.bean("ejercicios", "id=" + idejercicio);
        if ( beanEjercicio !== undefined ) {
            this.txtNombreEjercicioFiscal.text = beanEjercicio.fieldValue("nombre");
            this.txtCodEjercicioFiscal.text = beanEjercicio.fieldValue("codejercicio");
            this.dbcrbEjercicio.selectedBean = beanEjercicio;
        }
    }
    
    this.ui.pbAceptar.clicked.connect(this, "aceptar");
    this.ui.pbCancelar.clicked.connect(this, "cerrar");
}

ScriptDlg.prototype.cerrar = function()
{
    thisForm.close();
}

ScriptDlg.prototype.aceptar = function () 
{
    if ( this.idempresa == -1 ) {
        AERPMessageBox.information("No ha seleccionado una empresa. Debe seleccionar una empresa de trabajo");
        return;
    }
    if ( this.idejercicio == -1 ) {
        AERPMessageBox.information("No ha seleccionado un ejercicio fiscal. Debe seleccionar un ejercicio fiscal de trabajo");
        return;
    }
    AERPScriptCommon.setDbEnvVar("idempresa", this.idempresa);
    AERPScriptCommon.setDbEnvVar("idejercicio", this.idejercicio);
    thisForm.close();
}

/**
Esta función será llamada por dbcrbEmpresa automáticamente cuando el usuario escoga una empresa
*/
ScriptDlg.prototype.setEmpresa = function () 
{
    var beanEmpresa = this.dbcrbEmpresa.selectedBean;
    this.dbcrbEjercicio.value = null;
    this.txtCodEjercicioFiscal.text = "";
    this.txtNombreEjercicioFiscal.text = "";
    this.idejercicio = -1;
    if ( beanEmpresa != null ) {
        this.txtEmpresa.text = beanEmpresa.fieldValue("nombre");
        this.idempresa = beanEmpresa.fieldValue("id");
        this.dbcrbEjercicio.searchFilter = "idempresa=" + beanEmpresa.fieldValue("id");
    }
}

/**
Esta función será llamada por dbcrbEjercicio automáticamente cuando el usuario escoga un ejercicio
*/
ScriptDlg.prototype.setEjercicio = function () 
{
    var beanEjercicio = this.dbcrbEjercicio.selectedBean;
    if ( beanEjercicio != null ) {
        this.idejercicio = beanEjercicio.fieldValue("id");
        this.txtCodEjercicioFiscal.text = beanEjercicio.fieldValue("codejercicio");
        this.txtNombreEjercicioFiscal.text = beanEjercicio.fieldValue("nombre");
    }
}

