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
    // Si estamos creando movimiento de entrada, desde aquí, lo normal es querer introducir la referencia de proveedor, y por tanto
    // desde ahí, que se vayan creando la instancias
    if ( bean.stocksmovimientos.father.tipo.value == "Entrada" ) {
        this.ui.findChild("gbLocalizador").text = "Introduzca la referencia del proveedor para la creación de instancias de artículos";
        if ( bean.dbState == BaseBean.INSERT ) {
            // Hasta que no seleccionemos un artículo, no habilitamos la posibilidad de introducir referencias ni nada por el estilo...
            thisForm.db_localizador.dataEditable = false;
            thisForm.db_idarticulo.dataEditable = true;
        } else {
            thisForm.db_localizador.setFocus();
        }
    }
    this.chkCodBar = this.ui.findChild("chkCodBar");
    this.chkCodBar["stateChanged(int)"].connect(this, "ajustarLecturaCodBarras");
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

DBRecordDlg.prototype.idarticuloValueModified = function() {
    if ( bean.idarticulo.value > 0 && bean.stocksmovimientos.father.tipo.value == "Entrada" ) {
        thisForm.db_idinstancia.visible = bean.articulos.father.trazabilidad.value;
        thisForm.db_nombreinstancia.visible = bean.articulos.father.trazabilidad.value;
        // Hasta que no seleccionemos un artículo, no habilitamos la posibilidad de introducir referencias ni nada por el estilo...
        thisForm.db_localizador.dataEditable = true;
        thisForm.db_localizador.setFocus();
    }
}

DBRecordDlg.prototype.ajustarLecturaCodBarras = function() {
    thisForm.db_localizador.codeBarReaderAllowed = this.chkCodBar.checked;
    thisForm.db_localizador.dataEditable = this.chkCodBar.checked;
    if ( this.chkCodBar.checked ) {
        thisForm.db_localizador["barCodeReadReceived(QVariant)"].connect(this, "nuevaLecturaLocalizador");
    } else {
        thisForm.db_localizador["barCodeReadReceived(QVariant)"].disconnect(this, "nuevaLecturaLocalizador");
    }
    if ( bean.stocksmovimientos.father.tipo.value != "Entrada" ) {
        thisForm.db_idarticulo.dataEditable = !this.chkCodBar.checked;
        thisForm.db_idinstancia.dataEditable = !this.chkCodBar.checked;
        if ( this.chkCodBar.checked ) {
            thisForm.db_localizador["barCodeReadReceived(QVariant)"].connect(this, "nuevaLecturaLocalizador");
        } else {
            thisForm.db_localizador["barCodeReadReceived(QVariant)"].disconnect(this, "nuevaLecturaLocalizador");
        }
    }        
}

DBRecordDlg.prototype.nuevaLecturaLocalizador = function() {
    var idArticulo = bean.idarticulo.value;
    
    // Si estamos en entradas, se crean automaticamente las instancias de articulos
    if (bean.stocksmovimientos.father.tipo.value == "Entrada" && bean.dbState == BaseBean.INSERT && !bean.hasOwnProperty("init")) {
        bean.articulosinstancias.father = bean.articulos.father.articulosinstancias.newChild();
        bean.referencia.value = bean.articulosinstancias.father.referencia.value;
        bean.codbarras.value = bean.articulosinstancias.father.codbarras.value;
        bean.articulosinstancias.father.refproveedor.value = bean.refproveedor.value;
        bean.articulosinstancias.father.almacenes.father = bean.stocksmovimientos.father.almacendestino.father;
        bean.articulosinstancias.father.articuloscaracteristicasvalores.deleteAllChildren();
        bean["init"] = true;
        // Si la subfamilia tiene predefinidas algunas caracteristicas, las agregamos...
        if ( bean.articulos.father.idsubfamilia.value > 0 ) {
            var caracteristicas = AERPScriptCommon.beans("articuloscaracteristicasdefiniciones", "idsubfamilia=" + bean.articulos.father.idsubfamilia.value + " or idfamilia=" + bean.articulos.father.subfamiliasarticulos.father.idfamilia.value, "");
            for ( var i = 0 ; i < caracteristicas.length ; i++ ) {
                var caracteristica = bean.articulosinstancias.father.articuloscaracteristicasvalores.newChild();
                caracteristica.idcaracteristica.value = caracteristicas[i].id.value;
                caracteristica.articulos.father = bean.articulos.father;
            }
        }
    } else {
        var objArticulo = alepherp.almacen.articuloOInstanciaPorReferencia(thisForm.db_localizador.value);
        if ( objArticulo == null ) {
            AERPMessageBox("No existe ningún artículo con esa referencia");
            return;
        }
        bean.articulos.father = objArticulo.articulo;
        if ( objArticulo.isInstancia ) {
            bean.articulosinstancias.father = objArticulo.instancia;
        }
    }

    if ( this.chkCodBar.checked ) {
        thisForm.saveAndNew();
        bean.idarticulo.value = idArticulo;
    }
    
}

