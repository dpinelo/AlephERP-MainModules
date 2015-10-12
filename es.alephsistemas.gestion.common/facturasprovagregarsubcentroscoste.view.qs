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
    
    this.pbOk = this.ui.findChild("pbOk");
    this.pbCancel = this.ui.findChild("pbCancel");
    this.pbOk.clicked.connect(this, "agregarSubcentros");
    this.pbCancel.clicked.connect(this, "cerrar");
}

ScriptDlg.prototype.cerrar = function () {
    thisForm.close();
}

ScriptDlg.prototype.agregarSubcentros = function() {
    var beansSelected = thisForm.tvSubcentros.checkedBeans;
    var relationLineasCostes = thisForm.beanFactura.relation("lineasdistribucioncostesfacturasprov");
    var numSubcentros = 0;
    for ( var i = 0 ; i < beansSelected.length ; i++ ) {
        if ( beansSelected[i].metadata.tableName == "subcentroscoste" ) {
            numSubcentros++;
        }
    }
    var importe = (thisForm.beanFactura.fieldValue("neto") - thisForm.beanFactura.fieldValue("totalcostesdistribuidos")) / numSubcentros;
    if ( importe < 0 ) { 
        importe = 0;
    }    
    var porcentaje = (100 - thisForm.beanFactura.fieldValue("totalporcentajecostesdistribuidos")) / numSubcentros;
    if ( porcentaje < 0 ) {
        porcentaje = 0;
    }
    var total = (thisForm.beanFactura.fieldValue("total") - thisForm.beanFactura.fieldValue("totalcostesdistribuidos")) / numSubcentros;
    if ( total < 0 ) { 
        total = 0;
    }    
    for ( var i = 0 ; i < beansSelected.length ; i++ ) {
        if ( beansSelected[i].metadata.tableName == "subcentroscoste" ) {
            var child = relationLineasCostes.newChild();
            child.setFieldValue("nombrecentro", beansSelected[i].fatherFieldValue("centroscoste", "nombre"));
            child.setFieldValue("idcentro", beansSelected[i].fatherFieldValue("centroscoste", "id"));
            child.setFieldValue("nombresubcentro", beansSelected[i].fieldValue("nombre"));
            child.setFieldValue("idsubcentro", beansSelected[i].fieldValue("id"));
            child.setFieldValue("porcentaje", porcentaje);     
            child.setFieldValue("importe", importe);
            child.setFieldValue("total", total);
        }
    }
    thisForm.close();
}

