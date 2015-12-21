/** 
Este será el código compartido para poder agregar artículos, a presupuestos, pedidos, albaranes o facturas tanto de cliente  como de provedor.
Utilizamos prototype changing.
Es importante aclarar el comportamiento de la zona de almacén para las líneas de artículos. 
Por defecto, la línea de artículo almacenará si esta genera o no movimiento de stock. Pero eso no lo podrá determinar el usuario para garantizar integridad del almacén.
Todo viene de la definición de artículo. 
- Si el artículo NO controla stock, el usuario no verá las opciones de almacén (esto es, la ubicación desde la que se escoge el artículo).
- Si el artículo SÍ controla stock, y NO es instanciable, el usuario verá las opciones de almacén (para decidir desde qué almacén escoger el artículo).
- Si el artículo SÍ controla stock, y SÍ es instanciable, el usuario verá las opciones de almacén en modo lectura, ya que la ubicación desde la que saldrá será la que tenga la instancia.
El anterior comportamiento se determinará al escoger artículo o instancia.
*/

alepherp.DBRecordDlgLineasArticulosDocumentosGestion = function() {
}

alepherp.DBRecordDlgLineasArticulosDocumentosGestion.prototype.init = function(ui) {
    AERPLoadExtension("alepherp.almacen");
    this.ui = ui;

    if ( bean.dbState == BaseBean.INSERT ) {
        thisForm.db_recargo.visible = false;
        if ( this.ui.findChild("gbAlmacen") != null ) {
            this.ui.findChild("gbAlmacen").visible = false;
        }
    } else {
        thisForm.db_recargo.visible = bean.fieldValue("incluirrecargoequivalencia");
        this.establecerEstadoWidgetsAlmacen();
    }
    
    var articuloVisible = bean.metadata.tableName == "lineasarticulospresupuestoscli" ||
                          bean.metadata.tableName == "lineasarticulospedidiscli";
    thisForm.db_idarticulo.visible = articuloVisible;
    thisForm.db_articulos_nombre.visible = articuloVisible;
    thisForm.db_idinstancia.visible = !articuloVisible;
    thisForm.db_nombreinstancia.visible = !articuloVisible;
    
    // El filtro del IVA a seleccionar, se basa en la fecha de factura, del pedido o del albarán
    var padreTableName = bean.metadata.tableName.replace("lineasarticulos", "");
    this.beanPadre = bean.father(padreTableName);
    this.idimpuestoString = "idimpuestocompra";
    this.precioString = "coste";
    if ( bean.metadata.tableName.indexOf("cli") > -1 ) {
        this.idimpuestoString = "idimpuestoventa";
        this.precioString = "pvp";
        this.ui.findChild("lblDeduccionIva").visible = false;
        thisForm.db_tipooperacioniva.visible = false;
    } else {
        this.beanPadre = bean.father("pedidosprov");
        this.idimpuestoString = "idimpuestocompra";
        this.precioString = "coste"
        thisForm.db_idtarifa.visible = false;
        thisForm.db_tarifasnombre.visible = false;
    }
    if ( this.beanPadre.metadata.tableName == "facturasprov" || this.beanPadre.metadata.tableName == "facturascli" ) {
        this.ui.findChild("gbContabilidad").visible = this.beanPadre.empresas.father.contintegrada.value;
        if ( this.beanPadre.fatherFieldValue("seriesfacturacion", "tipoiva") != "Sujeta a I.V.A." ) {
            thisForm.db_idimpuesto.enabled = false;
            thisForm.db_iva.enabled = false;
            thisForm.db_periodosimpuestos_nombre.styleSheet = "background: #FFF395";
            thisForm.db_iva.styleSheet = "background: #FFF395";
        }
        if (bean.metadata.tableName == "lineasarticulosfacturasprov") {
            thisForm.db_codalbaran.fieldName = "lineasarticulosalbaranesprov.father.albaranesprov.father.codalbaran";
            thisForm.db_fechaalbaran.fieldName = "lineasarticulosalbaranesprov.father.albaranesprov.father.fecha";
        } else if (bean.metadata.tableName == "lineasarticulosfacturascli") {
            thisForm.db_codalbaran.fieldName = "lineasarticulosalbaranescli.father.albaranescli.father.codalbaran";
            thisForm.db_fechaalbaran.fieldName = "lineasarticulosalbaranescli.father.albaranescli.father.fecha";
        } else if (bean.metadata.tableName == "lineasserviciosfacturascli") {
            thisForm.db_codalbaran.fieldName = "lineasserviciosalbaranescli.father.albaranescli.father.codalbaran";
            thisForm.db_fechaalbaran.fieldName = "lineasserviciosalbaranescli.father.albaranescli.father.fecha";
        } else if (bean.metadata.tableName == "lineasserviciosfacturasprov") {
            thisForm.db_codalbaran.fieldName = "lineasserviciosalbaranesprov.father.albaranesprov.father.codalbaran";
            thisForm.db_fechaalbaran.fieldName = "lineasserviciosalbaranesprov.father.albaranesprov.father.fecha";
        }
    } else {
        this.ui.findChild("gbAlbaran").visible = false;
        this.ui.findChild("gbContabilidad").visible = false;
    }
    
    thisForm.db_idimpuesto.relationFilter = "fechadesde < " + this.beanPadre.fecha.sqlValue + " AND fechahasta > " + this.beanPadre.fecha.sqlValue;
}

alepherp.DBRecordDlgLineasArticulosDocumentosGestion.prototype.validate = function() {
    return true;
}

alepherp.DBRecordDlgLineasArticulosDocumentosGestion.prototype.beforeSave = function() {
   return true;
}

alepherp.DBRecordDlgLineasArticulosDocumentosGestion.prototype.beanSaved = function() {
   return;
}

alepherp.DBRecordDlgLineasArticulosDocumentosGestion.prototype.beforeNavigate = function() {
   return true;
}

alepherp.DBRecordDlgLineasArticulosDocumentosGestion.prototype.afterNavigate = function() {
    return;
}

alepherp.DBRecordDlgLineasArticulosDocumentosGestion.prototype.updateIVA = function() {
    var beanIVA = thisForm.db_idimpuesto.selectedBean;
    if ( beanIVA != null ) {
        bean.setFieldValue("iva", beanIVA.fieldValue("iva"));
        bean.setFieldValue("recargo", beanIVA.fieldValue("recargo"));
    }        
}

alepherp.DBRecordDlgLineasArticulosDocumentosGestion.prototype.updateIRPF = function() {
    var beanIRPF = thisForm.db_idimpuesto_irpf.selectedBean;
    if ( beanIRPF != null ) {
        bean.setFieldValue("irpf", beanIRPF.fieldValue("irpf"));
    }        
}

alepherp.DBRecordDlgLineasArticulosDocumentosGestion.prototype.incluirrecargoequivalenciaValueModified = function() {
    thisForm.db_recargo.visible = thisForm.db_incluirrecargoequivalencia.checked;
}

alepherp.DBRecordDlgLineasArticulosDocumentosGestion.prototype.idarticuloValueModified = function() {
    if ( bean.idarticulo.value > 0 ) {
        this.establecerEstadoWidgetsAlmacen();
        this.aplicarTarifaParaArticulo(bean.articulos.father);
        var idImpuesto = bean.fatherFieldValue("articulos", this.idimpuestoString);
        if ( idImpuesto === undefined ) {
            return;
        }
        var periodoImpuesto = AERPScriptCommon.bean("periodosimpuestos", "idimpuesto=" + idImpuesto + " and fechadesde < now() and fechahasta > now()");
        if ( periodoImpuesto === undefined ) {
            return;
        }        
        if ( bean.idimpuesto.value == null || bean.idimpuesto.value == 0 ) {
            bean.idimpuesto.value = periodoImpuesto.id.value;
            var impuestoCompra = bean.father("articulos").field(this.idimpuestoString).relation("impuestos").father;
            bean.iva.value = impuestoCompra.fieldValue("iva");
            bean.importesindto.value = bean.fatherFieldValue("articulos", this.precioString);
        } else {
            if ( bean.fatherFieldValue("articulos", this.idimpuestoString ) != bean.fieldValue("idimpuesto") ) {
                var ret = AERPMessageBox.question("¿Desea utilizar el IVA del nuevo artículo?", AERPMessageBox.Yes | AERPMessageBox.No);
                if ( ret == AERPMessageBox.Yes ) {
                    bean.idimpuesto.value = periodoImpuesto.id.value;
                    bean.iva.value = bean.fatherFieldValue("articulos", "iva");
                    bean.importesindto.value = bean.fatherFieldValue("articulos", this.precioString);
                }
            }
        }
        var articulo = bean.articulos.father;
        if ( bean.metadata.tableName == "lineasarticulosfacturascli" ) {
            if ( articulo.idsubcuentaventas.value > 0 ) {
                bean.idsubcuenta.value = articulo.idsubcuentaventas.value;
            } else if ( bean.facturascli.father.seriesfacturacion.father.idsubcuenta.value > 0 ) {
                bean.idsubcuenta.value = bean.facturascli.father.seriesfacturacion.father.idsubcuenta.value;
            }
        } else if ( bean.metadata.tableName == "lineasserviciosfacturasprov" ) {
            if ( articulo.idsubcuentacompras.value > 0 ) {
                bean.idsubcuenta.value = servicio.idsubcuentacompras.value;
            } else if ( bean.facturasprov.father.seriesfacturacion.father.idsubcuenta.value > 0 ) {
                bean.idsubcuenta.value = bean.facturasprov.father.seriesfacturacion.father.idsubcuenta.value;
            }
        }        
    }
}

alepherp.DBRecordDlgLineasArticulosDocumentosGestion.prototype.idtarifaValueModified = function() {
    if ( bean.idtarifa.value > 0 ) {
        bean.dtolineal.value = bean.tarifas.father.inclineal.value;
        bean.dtopor.value = bean.tarifas.father.incporcentual.value;
    }
}

alepherp.DBRecordDlgLineasArticulosDocumentosGestion.prototype.idinstanciaValueModified = function() {
    if ( bean.idinstancia.value > 0 ) {
        bean.idubicacion.value = bean.articulosinstancias.father.idubicacion.value;
        bean.idarticulo.value = bean.articulosinstancias.father.articulos.father.id.value;
        aplicarTarifaParaArticulo(bean.articulos.father);
    }
    this.establecerEstadoWidgetsAlmacen();
}

alepherp.DBRecordDlgLineasArticulosDocumentosGestion.prototype.aplicarTarifaParaArticulo = function(articulo) {
    // localizemos la tarifa que pertence al cliente actual
    if ( this.beanPadre.terceros.father.idtarifa.value > 0 ) {
        // ¿Es una tarifa de este artículo?
        for (var i = 0 ; i < articulo.articulostarifas.items.length ; i++) {
            if ( articulo.articulostarifas.items[i].idtarifa.value == this.beanPadre.terceros.father.idtarifa.value ) {
                bean.idtarifa.value = this.beanPadre.terceros.father.idtarifa.value;
                return;
            }
        }
        return;
    }
}

alepherp.DBRecordDlgLineasArticulosDocumentosGestion.prototype.establecerEstadoWidgetsAlmacen = function() {
    if ( bean.idarticulo.value > 0 ) {
        thisForm.db_idubicacion.visible = !bean.articulos.father.trazabilidad.value;
        thisForm.db_idubicacion.enabled = !bean.articulos.father.trazabilidad.value;
    }
    if ( bean.idinstancia.value > 0 ) {
        thisForm.db_idubicacion.visible = !bean.articulosinstancias.father.articulos.father.trazabilidad.value;
        thisForm.db_idubicacion.enabled = !bean.articulosinstancias.father.articulos.father.trazabilidad.value;
        thisForm.db_cantidad.readOnly = true;
    } else {
        thisForm.db_cantidad.readOnly = false;
    }    
}
