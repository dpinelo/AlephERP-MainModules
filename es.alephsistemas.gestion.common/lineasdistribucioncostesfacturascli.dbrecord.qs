function DBRecordDlg (ui) {
    loadExtension("qt.core");
    loadExtension("qt.gui");
    this.ui = ui;
    
    var fieldPorcentaje = bean.field("porcentaje");
    fieldPorcentaje['valueModified(QVariant)'].connect(this, "calcularImporte");
    var fieldImporte = bean.field("importe");
    fieldImporte['valueModified(QVariant)'].connect(this, "calcularPorcentaje");
}

DBRecordDlg.prototype.validate = function() {
    // Los importes sumados de todos estas líneas no deben superar el neto de la factura, así como los porcentajes no deben sumar más de 100
    var beanFactura = bean.father("facturascli");
    var lineasDistribucion = beanFactura.relationChilds("lineasdistribucioncostesfacturascli");
    var totalPorcentaje = 0, totalImportes = 0;
    for ( var i = 0 ; i < lineasDistribucion.length ; i++ ) {
        totalPorcentaje = totalPorcentaje + lineasDistribucion[i].fieldValue("porcentaje");
        totalImportes = totalImportes + lineasDistribucion[i].fieldValue("importe");    
    }
    if ( totalPorcentaje > 101 ) {
        var ret = AERPMessageBox.question("El porcentaje de costes imputados excede de 100%. ¿Está seguro de querer continuar?", AERPMessageBox.Yes |AERPMessageBox.No);
        if ( ret == AERPMessageBox.No ) {
            return false;
        }
    }
    if ( totalImportes > (beanFactura.neto.value + 1) ) {
        var ret = AERPMessageBox.question("Los importes distribuidos exceden el total de la factura. ¿Está seguro de querer continuar?", AERPMessageBox.Yes | AERPMessageBox.No);
        if ( ret == AERPMessageBox.No ) {
            return false;
        }            
    }
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

DBRecordDlg.prototype.calcularImporte = function() {
    bean.setFieldValue("importe", (bean.fieldValue("porcentaje") / 100) * bean.fatherFieldValue("facturascli", "neto"));
    bean.setFieldValue("total", (bean.fieldValue("porcentaje") / 100) * bean.fatherFieldValue("facturascli", "total"));
}

DBRecordDlg.prototype.calcularPorcentaje = function() {
    bean.setFieldValue("porcentaje", (bean.fieldValue("importe") * 100) / bean.fatherFieldValue("facturascli", "neto"));
}

DBRecordDlg.prototype.asignarCentroCoste = function() {
    var beanSubcentro = thisForm.db_idsubcentro.selectedBean;
    if ( beanSubcentro != null ) {
        bean.setFieldValue("idcentro", beanSubcentro.fieldValue("idcentrocoste"));    
        thisForm.db_nombrecentro.refresh();
        thisForm.db_nombresubcentro.refresh();        
    }
}

