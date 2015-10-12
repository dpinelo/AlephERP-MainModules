Function.prototype.bind = function() { 
    var func = this;
    var thisObject = arguments[0];
    var args = Array.prototype.slice.call(arguments, 1);
    return function() {
        return func.apply(thisObject, args);
    }
}

function DBRecordDlg (ui) {
    AERPLoadExtension("alepherp.almacen");
    
    this.ui = ui;
    
    this.tipoValueModified();
    
    if ( bean.dbState == BaseBean.UPDATE ) {
        thisForm.db_tipo.dataEditable = false;
        thisForm.db_nombrealmacendestino.text = bean.almacendestino.father.nombre.value;
        thisForm.db_nombrealmacenorigen.text = bean.almacenorigen.father.nombre.value;
    }
    thisForm.db_introrapida["textEdited(QString)"].connect(this, "introRapida");
}

DBRecordDlg.prototype.validate = function() {
    return true;
}

DBRecordDlg.prototype.beforeSave = function() {
    return true;
}

DBRecordDlg.prototype.beforeInitTransaction = function() {
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

DBRecordDlg.prototype.tipoValueModified = function() {
    var visible = false;
    thisForm.db_introrapida.visible = true;
    this.ui.findChild("lbl_introrapida").visible = true;
    if ( bean.tipo.value == "Entrada" ) {
        thisForm.db_idalmacendestino.dataEditable = true;
        thisForm.db_idalmacenorigen.dataEditable = false;
        thisForm.db_introrapida.visible = false;
        this.ui.findChild("lbl_introrapida").visible = false;
        this.ui.findChild("rbAlta").visible = false;
        this.ui.findChild("rbBaja").visible = false;
    } else if ( bean.tipo.value == "Salida" ) {
        thisForm.db_idalmacendestino.dataEditable = false;
        thisForm.db_idalmacenorigen.dataEditable = true;
        thisForm.db_introrapida.visible = false;
        this.ui.findChild("lbl_introrapida").visible = false;
        this.ui.findChild("rbAlta").visible = false;
        this.ui.findChild("rbBaja").visible = false;
    } else if ( bean.tipo.value == "Regularización" ) {
        thisForm.db_idalmacendestino.dataEditable = true;
        thisForm.db_idalmacenorigen.dataEditable = false;
        thisForm.db_introrapida.visible = true;
        this.ui.findChild("lbl_introrapida").visible = true;
        this.ui.findChild("rbAlta").visible = true;
        this.ui.findChild("rbBaja").visible = true;
    } else if ( bean.tipo.value == "Transferencia" ) {
        thisForm.db_idalmacendestino.dataEditable = true;
        thisForm.db_idalmacenorigen.dataEditable = true;
        thisForm.db_introrapida.visible = true;
        this.ui.findChild("lbl_introrapida").visible = true;
        this.ui.findChild("rbAlta").visible = false;
        this.ui.findChild("rbBaja").visible = false;
    }
}

DBRecordDlg.prototype.db_idalmacenorigenAfterChoose = function(selectedBean) {
    if ( selectedBean != null ) {
        thisForm.db_nombrealmacenorigen.text = selectedBean.nombre.value;
    }
}

DBRecordDlg.prototype.db_idalmacendestinoAfterChoose = function(selectedBean) {
    if ( selectedBean != null ) {
        thisForm.db_nombrealmacendestino.text = selectedBean.nombre.value;
    }
}

DBRecordDlg.prototype.introRapida = function() {
    var objArticulo = alepherp.almacen.articuloOInstanciaPorReferencia(thisForm.db_introrapida.value);
    
    if ( objArticulo != null ) {
        var instancia = bean.stocksmovimientosinstancias.newChild();
        if ( objArticulo.isInstancia ) {
            instancia.articulosinstancias.father = objArticulo.instancia;
            instancia.articulos.father = objArticulo.instancia.articulos.father;
        } else {
            instancia.articulos.father = objArticulo.articulo;
        }
        thisForm.db_introrapida.text = "";
    }
}

