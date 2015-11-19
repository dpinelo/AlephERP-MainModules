Function.prototype.bind = function() {
  var func = this;
  var thisObject = arguments[0];
  var args = Array.prototype.slice.call(arguments, 1);
  return function() {
    return func.apply(thisObject, args);
  }
}

function MainDlg(ui) {
    this.ui = ui;

    // Vamos a comprobar primero si estamos antes una instancia recién creada, vacía, y por tanto precargamos algunos datos
    precargarDatosSiNecesario();

    // Veamos ahora si el usuario tiene definido una empresa de trabajo y un ejercicio fiscal, si no, deberá
    // seleccionar uno
    var idempresa = AERPScriptCommon.envVar("idempresa");
    if ( idempresa != null ) {
        this.checkEjercicios();
    }
    var idejercicio = AERPScriptCommon.envVar("idejercicio");
    if ( idempresa == null || idejercicio == null ) {
        this.selectEntornoUsuario();
    }

    var action_entornousuario = thisForm.findChild("action_entornousuario");
    action_entornousuario.triggered.connect(this, "selectEntornoUsuario");
    var action_informes = thisForm.findChild("action_informes");
    action_informes.triggered.connect(this, "viewInformes");
}

MainDlg.prototype.checkEjercicios = function () 
{
    var idempresa = AERPScriptCommon.envVar("idempresa");
    var numEjercicios = AERPScriptCommon.sqlCount("ejercicios", "idempresa=" + idempresa);
    if ( numEjercicios == 0 ) {
        AERPMessageBox.information("No hay definido ningún ejercicio fiscal para esta empresa. Debe definir uno.");
        var dlg = new DBDialog;
        dlg.type = "record";
        dlg.tableName = "ejercicios";
        dlg.show();	
        if ( dlg.userClickOk ) {
            var recordEjercicio = dlg.selectedBean();
            AERPScriptCommon.setDbEnvVar("idejercicio", recordEjercicio.fieldValue("id"));
        }
    }
}

MainDlg.prototype.selectEntornoUsuario = function () 
{
    var dlg = new DBDialog;
    dlg.type = "script";
    dlg.uiName = "entornousuario.view.ui";
    dlg.qsName = "entornousuario.view.qs";
    dlg.show();
}

MainDlg.prototype.viewInformes = function ()
{
    var dlg = new DBDialog;
    dlg.type = "script";
    dlg.uiName = "viewjasperserverpage.script.ui";
    dlg.qsName = "viewjasperserverpage.script.qs";
    dlg.show();
}

