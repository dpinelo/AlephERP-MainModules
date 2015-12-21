function DBRecordDlg (ui) {
    AERPLoadExtension("alepherp.almacen");
    
    this.ui = ui;
    
    this.tipoValueModified();
    
    if ( bean.dbState == BaseBean.UPDATE ) {
        thisForm.db_tipo.dataEditable = false;
        thisForm.db_nombreubicaciondestino.text = bean.ubicaciondestino.father.nombre.value;
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
        thisForm.db_introrapida.visible = false;
        this.ui.findChild("lbl_introrapida").visible = false;
        this.ui.findChild("rbAlta").visible = false;
        this.ui.findChild("rbBaja").visible = false;
    } else if ( bean.tipo.value == "Salida" ) {
        thisForm.db_introrapida.visible = false;
        this.ui.findChild("lbl_introrapida").visible = false;
        this.ui.findChild("rbAlta").visible = false;
        this.ui.findChild("rbBaja").visible = false;
    } else if ( bean.tipo.value == "Regularización" ) {
        thisForm.db_introrapida.visible = true;
        this.ui.findChild("lbl_introrapida").visible = true;
        this.ui.findChild("rbAlta").visible = true;
        this.ui.findChild("rbBaja").visible = true;
    } else if ( bean.tipo.value == "Transferencia" ) {
        thisForm.db_introrapida.visible = true;
        this.ui.findChild("lbl_introrapida").visible = true;
        this.ui.findChild("rbAlta").visible = false;
        this.ui.findChild("rbBaja").visible = false;
    }
}

DBRecordDlg.prototype.db_idubicaciondestinoAfterChoose = function(selectedBean) {
    if ( selectedBean != null ) {
        thisForm.db_nombrealmacendestino.text = selectedBean.nombre.value;
    }
}

DBRecordDlg.prototype.introRapida = function() {
    var instancia = alepherp.almacen.instanciaPorReferencia(thisForm.db_introrapida.value);
    
    if ( instancia != undefined ) {
        var detalle = bean.stocksmovimientosinstancias.newChild();
        detalle.articulosinstancias.father = instancia.instancia;
        detalle.idubicacionorigen.value = instancia.idubicacion.value;
        detalle.idubicaciondestino.value = bean.idubicaciondestino.value;
        instancia.idmercadorigen.value = instancia.idmercado.value;
        if ( bean.idmercadodestino.value > 0 ) {
            detalle.idmercadodestino.value = bean.idmercadodestino.value;
        }
        thisForm.db_introrapida.text = "";
    }
}

