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

    // ¿Hay alguna divisa definida? Si no es así, creamos al menos EUROS
    var numDivisas = AERPScriptCommon.sqlCount("divisas", "");
    if ( numDivisas == 0 ) {
        var divisa = AERPScriptCommon.createBean("divisas");
        divisa.coddivisa.value = "EUR";
        divisa.descripcion.value = "Euros";
        divisa.save();
    }
    
    // Comprobemos primero que hay definida una empresa y un ejercicio fiscal actual, ya que si no,
    // habrá que crearlos. Se utiliza la función sqlCount del objeto de entorno de script AERPScriptCommon,
    // que dispone de funciones de ayuda al programador QS.
    var numEmpresas = AERPScriptCommon.sqlCount("empresas", "");
    if ( numEmpresas == -1 ) {
        AERPMessageBox.information("Ha ocurrido un error en el primer acceso a base de datos. No existe la tabla 'empresas'. La importación no se ha efectuado correctamente. No se puede iniciar la aplicación.");
        quitApplication();
        return;    
    } else if ( numEmpresas == 0 ) {
        AERPMessageBox.information("No hay definida ninguna empresa en el sistema. Debe iniciar AlephERP creando una primera empresa.");
        var dlg = new DBDialog;
        dlg.type = "record";
        dlg.tableName = "empresas";
        dlg.show();
        if ( dlg.userClickOk ) {
            var recordEmpresa = dlg.selectedBean();
            AERPScriptCommon.setDbEnvVar("idempresa", recordEmpresa.fieldValue("id"));
            this.checkEjercicios();
        } else {
            AERPMessageBox.information("No es posible iniciar AlephERP sin ninguna empresa.");
            quitApplication();
            return;
        }
    }

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

