Function.prototype.bind = function() { 
    var func = this;
    var thisObject = arguments[0];
    var args = Array.prototype.slice.call(arguments, 1);
    return function() {
        return func.apply(thisObject, args);
    }
}

function DBRecordDlg (ui) {
    loadExtension("qt.core");
    loadExtension("qt.gui");
    this.ui = ui;
    this.wasInsert = (bean.dbState == BaseBean.INSERT);
}

DBRecordDlg.prototype.validate = function() {
    return true;
}

DBRecordDlg.prototype.beforeSave = function() {
    return true;
}

DBRecordDlg.prototype.beanSaved = function() {
	if ( this.wasInsert ) {
		var now = new Date();
		// Comprobemos que no hay otro período abierto también.
		var impuesto = bean.father("impuestos");
		var periodos = impuesto.relationChilds("periodosimpuestos");
		for ( var i = 0 ; i < periodos.length ; i++ ) {
			if ( periodos[i].objectName != bean.objectName ) {
				if ( periodos[i].fieldValue("fechahasta") > now ) {
					QMessageBox.warning(thisForm, "AlephERP", "Existía un período anterior con fechas que lo hacían vigente. Se ha actualizado de modo que finaliza hoy");
					periodos[i].setFieldValue("fechahasta", now);
					periodos[i].save(false, false);
				}
			}
		}
	}
    return;
}

DBRecordDlg.prototype.beforeNavigate = function() {
    return true;
}

DBRecordDlg.prototype.afterNavigate = function() {
    return;
}
