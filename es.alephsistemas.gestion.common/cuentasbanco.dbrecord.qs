function DBRecordDlg (ui) {
    loadExtension("qt.core");
    loadExtension("qt.gui");
    this.ui = ui;
    var dbFieldCodEntidad = bean.field("codentidad");
    dbFieldCodEntidad['valueModified(QVariant)'].connect(this, "codEntidadChanged");
    
    // La función empresaActual está en __init__.js
    var empresa = empresaActual();
    if ( empresa.fieldValue("contintegrada") == false ) {
        thisForm.db_codsubcuenta.enabled = false;
        thisForm.db_codsubcuenta_text.enabled = false;
        thisForm.db_codsubcuentaecpg_text.enabled = false;
        thisForm.db_codsubcuentaecpg.enabled = false;
    }
}

DBRecordDlg.prototype.codEntidadChanged = function () 
{
    // Buscamos por el nombre del objeto (objectName de Qt) en el formulario
    // var dbSearchButtonCodSurcursal = this.ui.findChild("dbcrbCodSucursal");
    // En este formulario podemos hacer this.ui.dbcrbCodSucursal puesto que el control dbcrbCodSucursal
    // no se encuentra dentro de ningún contendor (QGroupBox, frame o demás)
    this.ui.dbcrbCodSucursal.relationFilter = "codentidad='" + bean.fieldValue("codentidad") + "'";
    this.ui.db_codsucursal.relationFilter = "codentidad='" + bean.fieldValue("codentidad") + "'";
}
