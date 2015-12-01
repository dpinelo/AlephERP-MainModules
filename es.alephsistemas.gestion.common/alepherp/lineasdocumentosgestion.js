/** 
Este será el código compartido para poder agregar servicios o artículos, a facturas, pedidos o albaranes tanto de cliente 
como de provedor.
Utilizamos prototype changing.
*/
Function.prototype.bind = function() { 
    var func = this;
    var thisObject = arguments[0];
    var args = Array.prototype.slice.call(arguments, 1);
    return function() {
        return func.apply(thisObject, args);
    }
}

alepherp.DBRecordDlgLineasDocumentosGestion = function() {
}

alepherp.DBRecordDlgLineasDocumentosGestion.prototype.init = function(ui) {
    AERPLoadExtension("alepherp.almacen");
    this.ui = ui;

    if ( bean.dbState == BaseBean.INSERT ) {
        thisForm.db_recargo.visible = false;
    } else {
        thisForm.db_recargo.visible = bean.fieldValue("incluirrecargoequivalencia");
    }
    // El filtro del IVA a seleccionar, se basa en la fecha de factura, del pedido o del albarán
    var beanPadre = bean.father("facturasprov");
    this.idimpuestoString = "idimpuestocompra";
    this.costeHoraString = "costehorarecibido";
    this.precioString = "coste";
    if ( beanPadre == null ) {
        beanPadre = bean.father("pedidoscli");
        this.idimpuestoString = "idimpuestoventa";
        this.costeHoraString = "costehoraaplicado";
        this.precioString = "pvp";
        this.ui.findChild("lblDeduccionIva").visible = false;
        thisForm.db_tipooperacioniva.visible = false;
    }
    if ( beanPadre == null ) {
        beanPadre = bean.father("albaranescli");
        this.idimpuestoString = "idimpuestoventa";
        this.costeHoraString = "costehoraaplicado";
        this.precioString = "pvp";
        this.ui.findChild("lblDeduccionIva").visible = false;
        thisForm.db_tipooperacioniva.visible = false;
    }
    if ( beanPadre == null ) {
        beanPadre = bean.father("facturascli");
        this.idimpuestoString = "idimpuestoventa";
        this.costeHoraString = "costehoraaplicado";
        this.precioString = "pvp";
        this.ui.findChild("lblDeduccionIva").visible = false;
        thisForm.db_tipooperacioniva.visible = false;
    }
    if ( beanPadre == null ) {
        beanPadre = bean.father("pedidosprov");
        this.idimpuestoString = "idimpuestocompra";
        this.precioString = "coste"
        this.costeHoraString = "costehorarecibido";
    }
    if ( beanPadre == null ) {
        beanPadre = bean.father("albaranesprov");
        this.idimpuestoString = "idimpuestocompra";
        this.precioString = "coste";
        this.costeHoraString = "costehorarecibido";
    }
    if ( beanPadre.metadata.tableName == "facturasprov" || beanPadre.metadata.tableName == "facturascli" ) {
        this.ui.findChild("gbContabilidad").visible = beanPadre.empresas.father.contintegrada.value;
        if ( beanPadre.fatherFieldValue("seriesfacturacion", "tipoiva") != "Sujeta a I.V.A." ) {
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
    if ( bean.metadata.tableName == "lineasarticulosalbaranesprov" ) {
        this.ui.findChild("lblReferencia").visible = false;
        thisForm.db_referencia.visible = false;
        thisForm.db_idinstancia.visible = false;
        thisForm.db_nombreinstancia.visible = false;
    }
    
    thisForm.db_idimpuesto.relationFilter = "fechadesde < " + beanPadre.fecha.sqlValue + " AND fechahasta > " + beanPadre.fecha.sqlValue;
    if ( thisForm.hasOwnProperty("db_referencia") ) {
        thisForm.db_referencia["textEdited(QString)"].connect(this, "introRapidaArticulos");
    }
    this.updateLabels();
}

alepherp.DBRecordDlgLineasDocumentosGestion.prototype.validate = function() {
    if ( bean.hasOwnProperty("generamovimientosstock" ) ) {
        if ( bean.generamovimientosstock.value == true && bean.idubicacion.value == 0 ) {
            AERPMessageBox.information("Para poder generar los movimientos de stocks correspondientes, debe escoger el almacén adecuado.");
            return false;
        }
        if ( bean.metadata.tableName == "lineasarticulosalbaranescli" || bean.metadata.tableName == "lineasarticulosfacturascli" ) {
            if ( bean.articulos.father.trazabilidad.value && bean.idinstancia.value == 0 ) {
                AERPMessageBox.information("Este artículo está marcado como artículo con trazabilidad activada. Eso implica que debe escoger qué instancia, o qué artículo concreto se va a incluir en este documento.");
                return false;
            }
        }
    }
    return true;
}

alepherp.DBRecordDlgLineasDocumentosGestion.prototype.beforeSave = function() {
   return true;
}

alepherp.DBRecordDlgLineasDocumentosGestion.prototype.beanSaved = function() {
   return;
}

alepherp.DBRecordDlgLineasDocumentosGestion.prototype.beforeNavigate = function() {
   return true;
}

alepherp.DBRecordDlgLineasDocumentosGestion.prototype.afterNavigate = function() {
    return;
}

alepherp.DBRecordDlgLineasDocumentosGestion.prototype.updateIVA = function() {
    var beanIVA = thisForm.db_idimpuesto.selectedBean;
    if ( beanIVA != null ) {
        bean.setFieldValue("iva", beanIVA.fieldValue("iva"));
        bean.setFieldValue("recargo", beanIVA.fieldValue("recargo"));
    }        
}

alepherp.DBRecordDlgLineasDocumentosGestion.prototype.updateIRPF = function() {
    var beanIRPF = thisForm.db_idimpuesto_irpf.selectedBean;
    if ( beanIRPF != null ) {
        bean.setFieldValue("irpf", beanIRPF.fieldValue("irpf"));
    }        
}

alepherp.DBRecordDlgLineasDocumentosGestion.prototype.incluirrecargoequivalenciaValueModified = function() {
    thisForm.db_recargo.visible = thisForm.db_incluirrecargoequivalencia.checked;
}

alepherp.DBRecordDlgLineasDocumentosGestion.prototype.idservicioValueModified = function() {
    if ( bean.idservicio.value > 0 ) {
        var idImpuesto = bean.fatherFieldValue("servicios", this.idimpuestoString);
        if ( idImpuesto == null || idImpuesto == undefined ) {
            return;
        }
        var periodoImpuesto = AERPScriptCommon.bean("periodosimpuestos", "idimpuesto=" + idImpuesto + " and fechadesde < now() and fechahasta > now()");
        if ( periodoImpuesto != null && periodoImpuesto != undefined ) {
            if ( bean.idimpuesto.value == null || bean.idimpuesto.value == 0 ) {
                bean.idimpuesto.value = periodoImpuesto.id.value;
                var impuesto;
                if ( bean.metadata.tableName.indexOf("prov") != -1 ) {
                    impuesto = bean.father("servicios").field(this.idimpuestoString).relation("impuestoscompra").father;
                } else {
                    impuesto = bean.father("servicios").field(this.idimpuestoString).relation("impuestosventa").father;
                }
                bean.iva.value = impuesto.fieldValue("iva");
                bean.importesindto.value = bean.fatherFieldValue("servicios", this.costeHoraString);
            } else {
                if ( bean.fatherFieldValue("servicios", this.idimpuestoString ) != bean.fieldValue("idimpuesto") ) {
                    var ret = AERPMessageBox.question("¿Desea utilizar el IVA del servicio seleccionado?", AERPMessageBox.Yes | AERPMessageBox.No);
                    if ( ret == AERPMessageBox.Yes ) {
                        bean.idimpuesto.value = periodoImpuesto.id.value;
                        bean.iva.value = bean.fatherFieldValue("servicios", "iva");
                        bean.importesindto.value = bean.fatherFieldValue("servicios", this.costeHoraString);
                    }
                }
            }
        }
        var servicio = bean.servicios.father;
        if ( bean.metadata.tableName == "lineasserviciosfacturascli" ) {
            if ( servicio.idsubcuentaventas.value > 0 ) {
                bean.idsubcuenta.value = servicio.idsubcuentaventas.value;
            } else if ( bean.facturascli.father.seriesfacturacion.father.idsubcuenta.value > 0 ) {
                bean.idsubcuenta.value = bean.facturascli.father.seriesfacturacion.father.idsubcuenta.value;
            }
        } else if ( bean.metadata.tableName == "lineasserviciosfacturasprov" ) {
            if ( servicio.idsubcuentacompras.value > 0 ) {
                bean.idsubcuenta.value = servicio.idsubcuentacompras.value;
            } else if ( bean.facturasprov.father.seriesfacturacion.father.idsubcuenta.value > 0 ) {
                bean.idsubcuenta.value = bean.facturasprov.father.seriesfacturacion.father.idsubcuenta.value;
            }
        }
        if ( servicio.tipoiva.value != "" ) {
            bean.tipoiva.value = servicio.tipoiva.value;
        }
        if ( servicio.tipooperacioniva.value != "" && bean.hasOwnProperty("tipooperacioniva") ) {
            bean.tipooperacioniva.value = servicio.tipooperacioniva.value;
        }
        this.updateLabels();
    }
}

alepherp.DBRecordDlgLineasDocumentosGestion.prototype.idarticuloValueModified = function() {
    if ( bean.idarticulo.value > 0 ) {
        bean.generamovimientosstock.value = bean.articulos.father.controlstock.value;
        if ( !bean.articulos.father.controlstock.value ) {
            thisForm.db_generamovimientosstock.enabled = false;
        }
        var idImpuesto = bean.fatherFieldValue("articulos", this.idimpuestoString);
        if ( idImpuesto == null || idImpuesto == undefined ) {
            return;
        }
        var periodoImpuesto = AERPScriptCommon.bean("periodosimpuestos", "idimpuesto=" + idImpuesto + " and fechadesde < now() and fechahasta > now()");
        if ( periodoImpuesto == null || periodoImpuesto == undefined ) {
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

alepherp.DBRecordDlgLineasDocumentosGestion.prototype.idinstanciaValueModified = function() {
    if ( bean.idinstancia.value > 0 ) {
        bean.idubicacion.value = bean.articulosinstancias.father.idubicacion.value;
        bean.idarticulo.value = bean.articulosinstancias.father.articulos.father.id.value;
        thisForm.db_cantidad.readOnly = true;
    } else {
        thisForm.db_cantidad.readOnly = false;
    }
}

alepherp.DBRecordDlgLineasDocumentosGestion.prototype.introRapidaArticulos = function() {
    if ( thisForm.db_referencia.text == "" || bean.generamovimientosstock.value == false ) {
        return;
    }
    var objArticulo = alepherp.almacen.articuloOInstanciaPorReferencia(thisForm.db_referencia.value);
    if ( objArticulo != null ) {
        var mensaje;
        if ( objArticulo.isInstancia  ) {
            // Si es una instancia, le asignamos a esta línea, el almacén donde esté
            if ( objArticulo.instancia.idubicacion.value > 0 ) {
                bean.idubicacion.value = objArticulo.instancia.idubicacion.value;
            }
            mensaje = alepherp.almacen.esPosibleSalidaArticulo(objArticulo.instancia, bean.idubicacion.value);
        }
        if ( !objArticulo.isInstancia ) {
            mensaje = alepherp.almacen.esPosibleSalidaArticulo(objArticulo.articulo, bean.idubicacion.value);
        }
        if ( mensaje != "" ) {
            AERPMessageBox.information(mensaje + " No puede ser agregado.");
            return;
        }
        if ( objArticulo.isInstancia ) {
            bean.articulosinstancias.father = objArticulo.instancia;
            bean.articulos.father = objArticulo.instancia.articulos.father;
        } else {
            bean.articulos.father = objArticulo.articulo;
        }
        bean.cantidad.value = 1;
        bean.importeunitario.value = objArticulo.articulo.pvp.value;
        thisForm.db_referencia.text = "";
    }
}

alepherp.DBRecordDlgLineasDocumentosGestion.prototype.updateLabels = function() {
    if ( bean.hasOwnProperty("idservicio") && bean.idservicio.value > 0 && bean.servicios.father.codunidadmedida.value != "" ) {
        this.ui.findChild("lblUnidad").text = bean.servicios.father.unidadesmedida.father.nombre.value;
    }
}

