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
    
    if ( bean.dbState == BaseBean.INSERT ) {
        if ( thisForm.parentType() == "DBDetailView" ) {
            this.ui.db_idarticulo.dataEditable = false;
            this.ui.db_idarticulo.enabled = false;
        }        
    } else {
        thisForm.db_stocksmovimientosentrada.relationFilter = ";stocksmovimientos.idalmacendestino=" + bean.idalmacen.value;
        thisForm.db_stocksmovimientossalida.relationFilter = ";stocksmovimientos.idalmacenorigen=" + bean.idalmacen.value;
    }   
}

DBRecordDlg.prototype.validate = function() {
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