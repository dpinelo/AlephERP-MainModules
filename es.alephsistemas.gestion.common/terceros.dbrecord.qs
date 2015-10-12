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

    bean.registerRecalculateFields("resumen_direccion_principal", "dirterceros");
    
    // Obtenemos y guardamos los objetos más habituales de la UI
    this.tbDatos = this.ui.findChild("tbDatos");
    this.tbComercial = this.ui.findChild("tbComercial");
    this.tbCuentasBancarias = this.ui.findChild("tbCuentasBancarias");
    this.tbDirecciones = this.ui.findChild("tbDirecciones");
    this.tbDocumentos = this.ui.findChild("tbDocumentos");
    this.tbContabilidad = this.ui.findChild("tbContabilidad");
    this.tbRelaciones = this.ui.findChild("tbRelaciones");
    this.tbInfoAdicional = this.ui.findChild("tbInfoAdicional");
    this.pbInsertarDireccionFacturacion = this.ui.findChild("pbInsertarDireccionFacturacion");
    this.pbEditarDireccionFacturacion = this.ui.findChild("pbEditarDireccionFacturacion");
    this.pbInsertarContactoPrincipal = this.ui.findChild("pbInsertarContactoPrincipal");
    this.pbEditarContactoPrincipal = this.ui.findChild("pbEditarContactoPrincipal");
    this.swTerceros = this.ui.findChild("swTerceros");

    this.tbDatos.checked = true;
    this.swTerceros.setCurrentWidget(this.ui.findChild("pageDatos"));

    this.tbDatos.clicked.connect(this, "showPage");
    this.tbComercial.clicked.connect(this, "showPage");
    this.tbCuentasBancarias.clicked.connect(this, "showPage");
    this.tbDirecciones.clicked.connect(this, "showPage");
    this.tbDocumentos.clicked.connect(this, "showPage");
    this.tbContabilidad.clicked.connect(this, "showPage");
    this.tbRelaciones.clicked.connect(this, "showPage");
    this.tbInfoAdicional.clicked.connect(this, "showPage");
    this.pbInsertarDireccionFacturacion.clicked.connect(this, "insertDirTercero");
    this.pbEditarDireccionFacturacion.clicked.connect(this, "editDirTercero");
    this.pbInsertarContactoPrincipal.clicked.connect(this, "insertContacto");
    this.pbEditarContactoPrincipal.clicked.connect(this, "editContacto");
        
    this.showDatosComerciales();
    
    bean.dirterceros['childModified(BaseBean*,bool)'].connect(this, "refreshMarksOnMap");
    
    var beanEmpresaActual = empresaActual();
    if ( beanEmpresaActual.fieldValue("contintegrada") == false ) {
        this.tbContabilidad.enabled = false;
    }
    
    if ( bean.dbState == BaseBean.UPDATE ) {
        this.refreshMarksOnMap();
    }
    
    thisForm.advancedNavigation = true;
}

DBRecordDlg.prototype.showPage = function() {
    if ( this.tbDatos.checked ) {
        this.swTerceros.setCurrentWidget(this.ui.findChild("pageDatos"));
    } else if ( this.tbComercial.checked ) {
        this.swTerceros.setCurrentWidget(this.ui.findChild("pageComercial"));
    } else if ( this.tbCuentasBancarias.checked ) {
        this.swTerceros.setCurrentWidget(this.ui.findChild("pageCuentasBancarias"));
    } else if ( this.tbDirecciones.checked ) {
        this.swTerceros.setCurrentWidget(this.ui.findChild("pageDirecciones"));
    } else if ( this.tbDocumentos.checked ) {
        this.swTerceros.setCurrentWidget(this.ui.findChild("pageDocumentos"));
    } else if ( this.tbContabilidad.checked ) {
        this.swTerceros.setCurrentWidget(this.ui.findChild("pageContabilidad"));
    } else if ( this.tbRelaciones.checked ) {
        this.swTerceros.setCurrentWidget(this.ui.findChild("pageRelaciones"));
    } else if ( this.tbInfoAdicional.checked ) {
        this.swTerceros.setCurrentWidget(this.ui.findChild("pageInfoAdicional"));
    }
}

DBRecordDlg.prototype.validate = function() {
    if ( bean.idgrupo.value > 0 ) {
        if ( bean.fatherFieldValue("gruposterceros", "nifobligatorio" ) == true && 
             ( bean.fieldValue("cifnif") == null || bean.fieldValue("cifnif") == "" ) ) {
            AERPMessageBox.warning("El grupo de tercero escogido, obliga a que este Tercero tenga un CIF o un NIF. Por favor, " +
                "introduzca un CIF o un NIF para este tercero.");
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
    this.refreshMarksOnMap();
    return;
}

DBRecordDlg.prototype.insertDirTercero = function() {
    var relationDir = bean.relation("dirterceros");
    // Si ya hay una dirección de domiciliación, no hacemos nada
    var otrasDireccionesDomiciliacion = relationDir.childByFilter("domfacturacion=true");
    if ( otrasDireccionesDomiciliacion != undefined && otrasDireccionesDomiciliacion != null ) {
        return;
    }
    
    var newDir = relationDir.newChild();
    newDir.setFieldValue("domfacturacion", true);
    
    var dlg = new DBDialog;
    dlg.type = "record";
    dlg.tableName = "dirterceros";
    dlg.beanToEdit = newDir;
    dlg.show();
    if ( !dlg.userClickOk ) {
        // Cada bean tiene un nombre único. Así lo identificamos para poder borrarlo.
        relationDir.removeChildByObjectName(newDir.objectName);
    }
}

DBRecordDlg.prototype.editDirTercero = function() {
    var relationDir = bean.relation("dirterceros");
    var otrasDireccionesDomiciliacion = relationDir.childByFilter("domfacturacion=true");
    if ( otrasDireccionesDomiciliacion === undefined || otrasDireccionesDomiciliacion == null ) {
        this.insertDirTercero();
        return;
    }

    // Necesario para que no se haga el commit hasta que el usuario haga click en este form
    otrasDireccionesDomiciliacion.canSaveOnDbDirectly = false;

    var dlg = new DBDialog;
    dlg.type = "record";
    dlg.tableName = "dirterceros";
    dlg.beanToEdit = otrasDireccionesDomiciliacion;
    dlg.show();
}

DBRecordDlg.prototype.insertContacto = function() {
    var relationContactos = bean.relation("contactos");
    // Si ya hay un contacto, no hacemos nada
    var otroContactoPrincipal = relationContactos.childByFilter("principal=true");
    if ( otroContactoPrincipal != undefined && otroContactoPrincipal != null ) {
        return;
    }

    var newContacto = relationContactos.newChild();
    // Necesario para que no se haga el commit hasta que el usuario haga click en este form
    newContacto.canSaveOnDbDirectly = false;
    newContacto.setFieldValue("principal", true);

    var dlg = new DBDialog;
    dlg.type = "record";
    dlg.tableName = "contactos";
    dlg.beanToEdit = newContacto;
    dlg.show();
    if ( !dlg.userClickOk ) {
        // Cada bean tiene un nombre único. Así lo identificamos para poder borrarlo.
        relationContactos.removeChildByObjectName(newContacto.objectName);
    }
}

DBRecordDlg.prototype.editContacto = function() {
    var relationContacto = bean.relation("contactos");
    var otroContactoPrincipal = relationContacto.childByFilter("principal=true");
    if ( otroContactoPrincipal === undefined || otroContactoPrincipal == null ) {
        this.insertContacto();
        return;
    }

    // Necesario para que no se haga el commit hasta que el usuario haga click en este form
    otroContactoPrincipal.canSaveOnDbDirectly = false;

    var dlg = new DBDialog;
    dlg.type = "record";
    dlg.tableName = "contactos";
    dlg.beanToEdit = otroContactoPrincipal;
    dlg.show();
}

DBRecordDlg.prototype.showDatosComerciales = function() {
    var gbComercial = this.ui.findChild("gbComercial");
    if ( bean.cliente.value ) {
        gbComercial.visible = true;
    } else {
        gbComercial.visible = false;
    }
}

DBRecordDlg.prototype.idgrupoValueModified = function() {
    if ( bean.gruposterceros.father.dbState != BaseBean.UPDATE && 
         bean.idserie.value != 0 && bean.gruposterceros.father.idserie.value != bean.idserie.value ) {
        var message = "Actualmente este tercero tiene como serie de facturación: <strong>" + 
            bean.fatherFieldValue("seriesfacturacion", "descripcion") + "</strong>. El nuevo grupo que ha escogido tiene " +
            "como serie de facturación: <strong>" + beanGrupo.fatherFieldValue("seriesfacturacion", "descripcion") + 
            "</strong>. ¿Desea tomar como serie de facturación ésta última?";
        var ret = AERPMessageBox.question(message, AERPMessageBox.Yes | AERPMessageBox.No);
        if ( ret == AERPMessageBox.No ) {
            return;
        }
    }
    var caracteristicas = AERPScriptCommon.beans("grupostercerosinfoadicional", "idgrupo=" + bean.idgrupo.value, "");
    for ( var i = 0 ; i < caracteristicas.length ; i++ ) {
        var caracteristica = bean.tercerosinfoadicional.newChild();
        caracteristica.nombre.value = caracteristicas[i].nombre.value;
    }
    bean.idserie.value = bean.gruposterceros.father.idserie.value;
}

DBRecordDlg.prototype.idplanpagoValueModified = function() {
    var beanGrupo = bean.father("gruposterceros");
    if ( bean.gruposterceros.father.dbState != BaseBean.UPDATE && 
        bean.idplanpago.value != 0 && bean.gruposterceros.father.idplanpago.value != bean.idplanpago.value ) {
        var message = "Actualmente este tercero tiene como plan de pago: <strong>" + 
                       bean.fatherFieldValue("planespago", "descripcion") + "</strong>. El nuevo grupo que ha escogido tiene " +
                       "como plan de pago: <strong>" + beanGrupo.fatherFieldValue("planespago", "descripcion") + 
                       "</strong>. ¿Desea tomar como plan de pago ésta última?";
        var ret = AERPMessageBox.question(message, AERPMessageBox.Yes | AERPMessageBox.No);
        if ( ret == AERPMessageBox.No ) {
            return;
        }
    }
    bean.idplanpago.value = bean.gruposterceros.father.idplanpago.value;
}

DBRecordDlg.prototype.refreshMarksOnMap = function() {
    thisForm.dbMapPosition.clearMarks();
    for (var i = 0 ; i < bean.dirterceros.items.length ;i++) {
        thisForm.dbMapPosition.addMark(bean.dirterceros.items[i].coordenadas.value, bean.dirterceros.items[i].direccion.value, bean.dirterceros.items[i].direccion.value);
    }
    thisForm.dbMapPosition.fitToShowAllMarkers();
}

DBRecordDlg.prototype.dbRelatedElementsViewAfterAddExisting = function(relatedElements) {
    var info = AERPScriptCommon.getText("Introduzca información adicional sobre esta relación.");
    for ( var i = 0 ; i < relatedElements.length ; i++ ) {
        relatedElements[i].additionalInfo = info;
    }
}

