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

    // Obtenemos y guardamos los objetos más habituales de la UI
    this.tbDatos = this.ui.findChild("tbDatos");
    this.tbLineas = this.ui.findChild("tbLineas");
    this.tbObservaciones = this.ui.findChild("tbObservaciones");
    this.tbEfectosCobro = this.ui.findChild("tbEfectosCobro");
    this.tbBolsas = this.ui.findChild("tbBolsas");
    this.swFichas = this.ui.findChild("swFichas");
    this.pbPagoRapido = this.ui.findChild("pbPagoRapido");

    this.swFichas.setCurrentWidget(this.ui.findChild("pageDatos"));
    this.tbDatos.checked = true;

    this.tbDatos.clicked.connect(this, "showPage");
    this.tbLineas.clicked.connect(this, "showPage");
    this.tbObservaciones.clicked.connect(this, "showPage");
    this.tbEfectosCobro.clicked.connect(this, "showPage");
    this.tbBolsas.clicked.connect(this, "showPage");

    if ( bean.dbState == BaseBean.INSERT ) {
        thisForm.db_iddirtercero.enabled = false;
    } else {
        thisForm.db_iddirtercero.searchFilter = "idtercero=" + bean.fieldValue("idtercero");
    }

	this.pbPagoRapido.clicked.connect(this, "crearPagoRapido");
    // Cuando se guarde una línea, se generan las líneas de IVA
    var relationLineasArticulos = bean.relation("lineasarticulospedidosprov");
    var relationLineasServicios = bean.relation("lineasserviciospedidosprov");
    relationLineasArticulos['childSaved(BaseBean*)'].connect(this, "calcularImpuestos");
    relationLineasServicios['childSaved(BaseBean*)'].connect(this, "calcularImpuestos");  
}

DBRecordDlg.prototype.showPage = function() {
    if ( this.tbDatos.checked ) {
        this.swFichas.setCurrentWidget(this.ui.findChild("pageDatos"));
    } else if ( this.tbLineas.checked ) {
        this.swFichas.setCurrentWidget(this.ui.findChild("pageLineas"));
    } else if ( this.tbObservaciones.checked ) {
        this.swFichas.setCurrentWidget(this.ui.findChild("pageObservaciones"));
    } else if ( this.tbEfectosCobro.checked ) {
        this.swFichas.setCurrentWidget(this.ui.findChild("pageEfectosCobro"));
    } else if ( this.tbBolsas.checked ) {
        this.swFichas.setCurrentWidget(this.ui.findChild("pageBolsas"));
    }
}

DBRecordDlg.prototype.validate = function() {
    return true;
}

DBRecordDlg.prototype.beforeSave = function() {
    // Antes de guardar el formulario maestro, se generan siempre las líneas de IVA y se calculan los IRPF
    this.calcularImpuestos();
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

DBRecordDlg.prototype.terceroWasSelected = function() {
    var beanTercero = thisForm.db_idtercero.selectedBean;
    if ( beanTercero != null ) {
        if ( bean.fieldValue("idserie") == 0 ) {
            bean.setFieldValue("idserie", beanTercero.fatherFieldValue("gruposterceros", "idserie"));
        }
        if ( bean.fieldValue("idplanpago") == 0 ) {
            bean.setFieldValue("idplanpago", beanTercero.fieldValue("idplanpago"));
        }
        bean.setFieldValue("iddirtercero", 0);
        bean.setFieldValue("nombredirtercero", "");
        thisForm.db_iddirtercero.searchFilter = "idtercero=" + beanTercero.fieldValue("id");
    }
}

DBRecordDlg.prototype.idterceroValueModified = function() {
    thisForm.db_iddirtercero.enabled = true;
}

DBRecordDlg.prototype.calcularImpuestos = function() {
    var lineasArticulos = bean.relationChilds("lineasarticulospedidosprov");
    var lineasServicios = bean.relationChilds("lineasserviciospedidosprov");
    var relationLineasIVA = bean.relation("lineasivapedidosprov");
    var irpf = 0;
    relationLineasIVA.deleteAllChilds();

    // Empezamos a generar las líneas de IVA. Sólo tenemos que establecer el neto (base imponible) y los porcentajes
    // de IVA o de recargo de equivalencia, ya que los totales de la línea son campos calculados cuyas fórmulas y/o scripts
    // están definidos en el table.
    for ( var iArticulo = 0 ; iArticulo < lineasArticulos.length ; iArticulo++ ) {
        var lineaIVA = relationLineasIVA.childByField("idimpuesto", lineasArticulos[iArticulo].fieldValue("idimpuesto"));
        if ( lineaIVA == null ) {
            lineaIVA = relationLineasIVA.newChild();
            lineaIVA.setFieldValue("idimpuesto", lineasArticulos[iArticulo].fieldValue("idimpuesto"));
            var ivaArticulo = lineasArticulos[iArticulo].fieldValue("iva");
            lineaIVA.setFieldValue("iva", ivaArticulo);
            if ( lineasArticulos[iArticulo].fieldValue("incluirrecargoequivalencia") ) {
                lineaIVA.setFieldValue("recargo", lineasArticulos[iArticulo].fieldValue("recargo"));
            }
        }
        lineaIVA.setFieldValue("neto", 0 + lineaIVA.fieldValue("neto") + lineasArticulos[iArticulo].fieldValue("importetotal"));
        irpf = irpf + ( lineaIVA.fieldValue("neto") * (lineasArticulos[iArticulo].fieldValue("irpf") / 100) );
    }
    for ( var iServicio = 0 ; iServicio < lineasServicios.length ; iServicio++ ) {
        var lineaIVA = relationLineasIVA.childByField("idimpuesto", lineasServicios[iServicio].fieldValue("idimpuesto"));
        if ( lineaIVA == null ) {
            lineaIVA = relationLineasIVA.newChild();
            lineaIVA.setFieldValue("idimpuesto", lineasServicios[iServicio].fieldValue("idimpuesto"));
            var ivaServicio = lineasServicios[iServicio].fieldValue("iva");
            lineaIVA.setFieldValue("iva", ivaServicio);
            if ( lineasServicios[iServicio].fieldValue("incluirrecargoequivalencia") ) {
                lineaIVA.setFieldValue("recargo", lineasArticulos[iArticulo].fieldValue("recargo"));
            }
        }
        lineaIVA.setFieldValue("neto", 0 + lineaIVA.fieldValue("neto") + lineasServicios[iServicio].fieldValue("importetotal"));
        irpf = irpf + ( lineaIVA.fieldValue("neto") * (lineasServicios[iServicio].fieldValue("irpf") / 100) );
    }
    bean.setFieldValue("totalirpf", irpf);
}

DBRecordDlg.prototype.crearPagoRapido = function() 
{
    var dlg = new DBDialog;
    dlg.type = "script";
    dlg.uiName = "crearpagorapido.view.ui";
    dlg.qsName = "crearpagorapido.view.qs";
    dlg.addPropertyValueToThisForm("importeMax", bean.fieldValue("importe"));
    dlg.show();

    var userClickOk = dlg.readPropertyFromThisForm("userClickOk");
    if ( userClickOk ) {
        // Obtengamos cuenta bancaria, si hay que escogerla.
        var cuentaBanco = undefined;
        if ( dlg.readPropertyFromThisForm("idcuentabanco") > 0 ) {
            cuentaBanco = AERPScriptCommon.bean("cuentasbanco", "id=" + dlg.readPropertyFromThisForm("idcuentabanco"));
        }
        // Creamos el efecto de pago
        var beanEfectoCobro = bean.newRelationChild("efectoscobro");
        beanEfectoCobro.setFieldValue("importe", dlg.readPropertyFromThisForm("importe"));
        beanEfectoCobro.setFieldValue("fecha", dlg.readPropertyFromThisForm("fecha"));
        beanEfectoCobro.setFieldValue("fechav", dlg.readPropertyFromThisForm("fecha"));
        beanEfectoCobro.setFieldValue("coddivisa", bean.fieldValue("coddivisa"));
        beanEfectoCobro.setFieldValue("tasaconv", bean.fieldValue("tasaconv"));
        beanEfectoCobro.setFieldValue("idtercero", bean.fieldValue("idtercero"));
        beanEfectoCobro.setFieldValue("idtercero", bean.fieldValue("idtercero"));
        beanEfectoCobro.setFieldValue("nombretercero", bean.fieldValue("nombre"));
        beanEfectoCobro.setFieldValue("cifnif", bean.fieldValue("cifnif"));
        beanEfectoCobro.setFieldValue("direccion", bean.fieldValue("direccion"));
        beanEfectoCobro.setFieldValue("codpostal", bean.fieldValue("codpostal"));
        beanEfectoCobro.setFieldValue("poblacion", bean.fieldValue("ciudad"));
        beanEfectoCobro.setFieldValue("codpais", bean.fieldValue("codpais"));
                                                
        beanEfectoCobro.setFieldValue("idcuenta", dlg.readPropertyFromThisForm("idcuentabanco"));
        if ( dlg.readPropertyFromThisForm("idcuentabanco") > 0 ) {
            beanEfectoCobro.setFieldValue("descripcion", cuentaBanco.fieldValue("descripcion"));
            beanEfectoCobro.setFieldValue("ctaentidad", cuentaBanco.fieldValue("ctaentidad"));
            beanEfectoCobro.setFieldValue("ctaagencia", cuentaBanco.fieldValue("ctaagencia"));
            beanEfectoCobro.setFieldValue("dc", cuentaBanco.fieldValue("dc"));
            beanEfectoCobro.setFieldValue("cuenta", cuentaBanco.fieldValue("cuenta"));
        }                             
        beanEfectoCobro.save();
        
        // Y ahora el cobro en sí
        var cobro = beanEfectoCobro.newRelationChild("cobrosdevoluciones");
        cobro.setFieldValue("idformapago", dlg.readPropertyFromThisForm("idformapago"));
        cobro.setFieldValue("fecha", dlg.readPropertyFromThisForm("fecha"));
        cobro.setFieldValue("tipo", "Pago");
        if ( dlg.readPropertyFromThisForm("idcuentabanco") > 0 ) {
            cobro.setFieldValue("descripcion", cuentaBanco.fieldValue("descripcion"));
            cobro.setFieldValue("ctaentidad", cuentaBanco.fieldValue("ctaentidad"));
            cobro.setFieldValue("ctaagencia", cuentaBanco.fieldValue("ctaagencia"));
            cobro.setFieldValue("dc", cuentaBanco.fieldValue("dc"));
            cobro.setFieldValue("cuenta", cuentaBanco.fieldValue("cuenta"));
        }
        cobro.save();
    }
}
