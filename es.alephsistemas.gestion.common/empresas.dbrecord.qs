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
}

/** Esta función es llamada automáticamente por el motor de AlephERP justo antes de guardar el registro
en base de datos. Permite al desarrollador de QS realizar una validación determinada. Debe devolver
true o false OBLIGATORIAMENTE */
DBRecordDlg.prototype.validate = function () 
{
    // Comprobemos si al introducir una empresa, el usuario ha definido ejercicios fiscales. Si no
    // es así, se lo avisamos
    var numEjercicios = bean.relationChildsCount("ejercicios", false);
    if ( numEjercicios < 1 ) {
        var ret = AERPMessageBox.question("No ha definido ningún ejercicio fiscal asociado a esta empresa. No podrá trabajar de forma efectiva con esta empresa. ¿Desea continuar?", AERPMessageBox.Yes, AERPMessageBox.No);
        if ( ret == AERPMessageBox.No ) {
            return false;
        }
    }
    return true;
}
