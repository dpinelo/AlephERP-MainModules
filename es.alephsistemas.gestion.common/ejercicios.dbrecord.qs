function DBRecordDlg (ui) {
    AERPLoadExtension("qt.core");
    AERPLoadExtension("qt.gui");
    
    this.ui = ui;

    if ( bean.empresas.father.contintegrada.value == false ) {
        var tabWidget = this.ui.findChild("tabWidget");
        //tabWidget.setTabEnabled(1, false);
    } else {
        if ( bean.co_cuentasesp.items.length == 0 && bean.pgactivo.value ) {
            bean.aerpGenerarCuentasEspeciales.call();
        }
    }
    thisForm.dbDetailView.createPushButton(6, "Copiar Series Facturación", 
                "Copia series de facturación de un ejercicio anterior", ":/generales/images/copyrecord.png", "copiarSeriesFacturacion");
    
    //Ocultar boton si no existen ejerccios anteriores.
     if(bean.empresas.father.ejercicios.items.length < 1) {
        thisForm.findChild("pb_copiarejercicio").visible = false;
    }
    //Ocultar boton si ya han sido generado los datos.
    if(bean.pgactivo.value == true) {
        thisForm.findChild("pb_copiarejercicio").visible = false;
        thisForm.findChild("pb_generarejercicio").visible = false;
    }

    //Funciones para cuando hagamos clic en los botones de Generar Ejercicio o Copiar Ejercicio
    thisForm.findChild("pb_copiarejercicio").clicked.connect(this, "copiarEjercicioAnterior");
    thisForm.findChild("pb_generarejercicio").clicked.connect(this, "generarPlanContable");
    
    this.longsubcuentaValueModified();
}

/** Esta función es llamada automáticamente por el motor de AlephERP justo antes de guardar el registro
en base de datos. Permite al desarrollador de QS realizar una validación determinada. Debe devolver
true o false OBLIGATORIAMENTE */
DBRecordDlg.prototype.validate = function () 
{
    return true;
}

/** Esta función se llama automáticamente por el motor de AlephERP justo después de que el registro (bean)
se haya guardado correctamente. */
DBRecordDlg.prototype.beanSaved = function ()
{
}

DBRecordDlg.prototype.longsubcuentaValueModified = function() {
    var ejemploSubcuenta = "4300";
    for (var i = 1 ; i <= bean.longsubcuenta.value ; i++){
        ejemploSubcuenta = ejemploSubcuenta + "" + i;
    }
    this.ui.findChild("leEjemploSubcuenta").text = ejemploSubcuenta;
}

DBRecordDlg.prototype.copiarSeriesFacturacion = function() 
{
    var ejercicio = AERPScriptCommon.chooseRecordFromComboBox("ejercicios", "nombre", "", "", "Seleccione el ejercicio desde el que copiar las series de facturación");
    if ( ejercicio != null ) {
        var series = ejercicio.seriesfacturacion.items;
        for ( var i = 0 ; i < series.length ; i++ ) {
            var nuevaSerie = bean.seriesfacturacion.newChild();
            nuevaSerie.copyValues(series[i], "codserie", "descripcion", "tipoiva", "tipooperacion", "seriecompra", "serieventa", "ignoracontabilidad", "counter_prefix",
                                             "codcuenta", "idcuenta", "tipooperacioniva");
        }
    }
}

//Copia un ejercicio anterior. 
DBRecordDlg.prototype.copiarEjercicioAnterior = function() {
    var ejercicioAnterior = AERPScriptCommon.chooseRecordFromComboBox("ejercicios", "nombre", "", "", "Seleccione el ejercicio del que quiere importar la información.");
    if ( ejercicioAnterior != null ) {
        //Obtenemos el numero de grupos que tiene ejercicio anterior.
        var grupoHijos = ejercicioAnterior.co_grupos.items;
        for (var i = 0 ; i<grupoHijos.length ; i++) {
            //Creamos el nuevo Grupo.
            var grupo = bean.co_grupos.newChild();
            AERPScriptCommon.addToTransaction(grupo);
            grupo.codgrupo.value = grupoHijos[i].codgrupo.value;
            grupo.descripcion.value = grupoHijos[i].descripcion.value;
            grupo.validate();
            //Obtenemos el numero de subGrupos que tiene cada grupo.
            var subGrupoHijos = grupoHijos[i].co_subgrupos.items;
            for(var j = 0 ; j<subGrupoHijos.length ; j++) {
                //Creamos el nuevo Subgrupo
                var subGrupo = grupo.co_subgrupos.newChild();
                subGrupo.codsubgrupo.value = subGrupoHijos[j].codsubgrupo.value;
                subGrupo.descripcion.value = subGrupoHijos[j].descripcion.value;
                subGrupo.validate();
                //Obtenemos el numero de subGrupos que tiene cada grupo.
                var cuentaHijos = subGrupoHijos[j].co_cuentas.items;
                for(var k = 0 ; k < cuentaHijos.length ; k++) {
                    //Creamos la nueva Cuenta.
                    var cuenta = subGrupo.co_cuentas.newChild();
                    cuenta.codcuenta.value = cuentaHijos[k].codcuenta.value;
                    cuenta.descripcion.value = cuentaHijos[k].descripcion.value;
                    cuenta.validate();
                }
            }
            if(!AERPScriptCommon.commit()){
                bean.co_grupos.deleteAllChildren();
                return;
            }
        }
        bean.pgactivo.value = true;
        thisForm.findChild("pb_copiarejercicio").visible = false;
        thisForm.findChild("pb_generarejercicio").visible = false;
    }
}

DBRecordDlg.prototype.generarCuentasEspeciales = function() {
    bean.aerpGenerarCuentasEspeciales.call();
}

//Genera un ejercicio por defecto segun Plan General Contable elegido.
DBRecordDlg.prototype.generarPlanContable = function() {
    if ( bean.plancontable.value == "" || bean.plancontable.value == null )  {
        AERPMessageBox.warning("Debe seleccionar qué plan contable desea generar");
        return;
    }
    var ret = AERPMessageBox.question("Se va a proceder a guardar el registro actual antes de generar el plan general contable. ¿Está seguro de querer continuar?",
                AERPMessageBox.Yes | AERPMessageBox.No);
    if ( ret == AERPMessageBox.No ) {
        return;
    }
    if ( !thisForm.validate() || !thisForm.save() ) {
        return;
    }
    var pcg =  thisForm.findChild("db_plancontable").value;
    var pcgDir;
    
    switch (pcg) {
        case "2007":
                pcgDir = AERPScriptCommon.getSystemObjectPath("pgc2007.ods", "binary");
            break;
        case "2007pyme":
                pcgDir = AERPScriptCommon.getSystemObjectPath("pgc2007abreviado.ods", "binary");
            break;
        case "2010ent":
                pcgDir = AERPScriptCommon.getSystemObjectPath("pgc2007entidadessinlucro.ods", "binary");
            break;
        case "2010entabr":
                pcgDir = AERPScriptCommon.getSystemObjectPath("pgc2007entidadessinlucro-abreviado.ods", "binary");
            break;
        default:
            AERPMessageBox.warning("Debe elegir un Plan Contable.");
            return;
    }
    
    var archOds =  AERPScriptCommon.openSpreadSheet(pcgDir, "ods");
    var sheetArchOds = archOds.sheet(0);
    if (sheetArchOds == null) {
        AERPMessageBox.warning("Ruta del archivo ods incorrecta.");
        return;
    } else {
        AERPScriptCommon.showProgressDialog("Generando Plan Contable...", 3 * sheetArchOds.rowCount);
        //Tres iteraciones, una por cada nivel (desde grupos a cuentas)
        for(var i=0;  i < 3 ; i++){ 
            //Recorremos todas las lineas del ods
            for(var line = 0; line < sheetArchOds.rowCount ; line++) {
                //Dependiendo de la iteración (desde grupo a cuenta)
                var id = sheetArchOds.cellValue(line,0) + "";
                switch (i) {
                    //Grupos
                    case 0:
                        if (id.length == 1) {
                            var grupo = bean.co_grupos.newChild();
                            AERPScriptCommon.addToTransaction(grupo);
                            grupo.codgrupo.value = sheetArchOds.cellValue(line,0) + "";
                            grupo.descripcion.value = sheetArchOds.cellValue(line,1);
                        }
                        break;
                    //Subgrupos
                    case 1:
                        if (id.length == 2) {
                            var subGrupo = bean.co_grupos.childByField("codgrupo",id.substr(0,1)).co_subgrupos.newChild();
                            subGrupo.codsubgrupo.value = sheetArchOds.cellValue(line,0) + "";
                            subGrupo.descripcion.value = sheetArchOds.cellValue(line,1);
                        }
                        break;
                    //Cuentas
                    case 2:
                        if (id.length == 3) {
                            var cuenta = bean.co_grupos.childByField("codgrupo",id.substr(0,1)).co_subgrupos.childByField("codsubgrupo",id.substr(0,2)).co_cuentas.newChild();
                            cuenta.codcuenta.value = sheetArchOds.cellValue(line,0) + "0";
                            cuenta.descripcion.value = sheetArchOds.cellValue(line,1);
                            var subcuenta = cuenta.co_subcuentas.newChild();
                            subcuenta.codsubcuenta.value = AERPScriptCommon.leftJustified(cuenta.codcuenta.value, "0", 4 + bean.longsubcuenta.value);
                            subcuenta.descripcion.value = cuenta.descripcion.value;
                            subcuenta.debe.value = 0;
                            subcuenta.haber.value = 0;
                            subcuenta.saldo.value = 0;
                        }
                        break;
                }
                AERPScriptCommon.setValueProgressDialog((i * sheetArchOds.rowCount) + line);
            }
        }
        var r = AERPScriptCommon.commit(false);
        AERPScriptCommon.closeProgressDialog();
        if ( !r ){
            bean.co_grupos.deleteAllChildren();
            AERPMessageBox.warning("Ha ocurrido un error. No se ha podido crear la estructura.\nEl error es: " + AERPScriptCommon.lastError);
        } else {
            thisForm.restoreContext();
            bean.pgactivo.value = true;
            bean.aerpGenerarCuentasEspeciales.call();
            if ( !thisForm.validate() || !thisForm.save() ) {
                return;
            }
            thisForm.findChild("pb_copiarejercicio").visible = false;
            thisForm.findChild("pb_generarejercicio").visible = false;
        }
    }
}