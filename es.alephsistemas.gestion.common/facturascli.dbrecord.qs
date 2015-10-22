function DBRecordDlg (ui) {
    this.init(ui);
    this.tbCoberturas = this.ui.findChild("tbCoberturas");
    this.tbCoberturas.clicked.connect(this, "showCoberturas");
    this.pbRecalcularServicios = this.ui.findChild("pbRecalcularServicios");
    this.pbRecalcularServicios.clicked.connect(this, "actualizarServicioCoberturas");
    if ( bean.dbState == BaseBean.INSERT ) {
        if ( thisForm.parentDialog == null || thisForm.parentDialog.tableName == "alepherp_operaciones" ) {
            var empresa = empresaActual();
            if ( empresa != undefined && empresa != null && empresa.idseriefacturacioncoberturas.value > 0 ) {
                // Vamos a evitar problemas al coger series de facturación de otra empresa...
                if ( empresa.idseriefacturacioncoberturas.seriesfacturacion.father.idempresa.value == empresa.id.value ) {
                    bean.idserie.value = empresa.idseriefacturacioncoberturas.value;
                }
            }
        }
    }
}

// Aquí se produce la herencia del código compartido entre los documentos de gestión (pedidos, albaranes, facturas...)
AERPLoadExtension("alepherp");
DBRecordDlg.prototype = new alepherp.DBRecordDlgDocumentosGestion();

DBRecordDlg.prototype.showCoberturas = function() 
{
    if ( this.tbCoberturas.checked ) {
        this.swFichas.setCurrentWidget(this.ui.findChild("pageCoberturas"));
    }
}

DBRecordDlg.prototype.alepherp_expedicionesAddExisting = function()
{
    this.actualizarServicioCoberturas();
}

DBRecordDlg.prototype.alepherp_expedicionesRemoveExisting = function()
{
    this.actualizarServicioCoberturas();
}

DBRecordDlg.prototype.alepherp_informe_fundicionAddExisting = function()
{
    this.actualizarServicioFundiciones();
}

DBRecordDlg.prototype.alepherp_informe_fundicionRemoveExisting = function()
{
    this.actualizarServicioFundiciones();
}

DBRecordDlg.prototype.actualizarServicioCoberturas = function()
{
    var beanServicio = AERPScriptCommon.bean("servicios", "idempresa=" + AERPScriptCommon.envVar("idempresa") + " and codigointernoservicio='COBERTURAS'");
    if ( beanServicio == undefined || beanServicio == null ) {
        AERPMessageBox.warning("El sistema no tiene un servicio configurado para almacenar las coberturas");
        return;
    }
    var idServicioCobertura = beanServicio.id.value;
    // Habrá un detalle por cobertura. Así que lo más fácil es borrar los anteriores detalles.
    for (var i = 0 ; i < bean.lineasserviciosfacturascli.items.length ; i++) {
        if ( bean.lineasserviciosfacturascli.items[i].dbState != BaseBean.TO_BE_DELETED && 
            bean.lineasserviciosfacturascli.items[i].idservicio.value == idServicioCobertura ) {
            bean.lineasserviciosfacturascli.items[i].dbState = BaseBean.TO_BE_DELETED;
        }
    }
    for (var i = 0 ; i < bean.alepherp_expediciones.items.length ; i++) {
        var expedicion = bean.alepherp_expediciones.items[i];
        var importes = new Array();
        var gramos = new Array();
        var coberturas = new Array();
        
        for (var iBolsa = 0 ; iBolsa < expedicion.alepherp_informe_analisis_bolsas.items.length ; iBolsa++ ) {
            var bolsa = expedicion.alepherp_informe_analisis_bolsas.items[iBolsa];
            var analisis = bolsa.alepherp_informe_analisis.father;
            var cobertura = analisis.alepherp_coberturas.father;
            var coberturaEncontrada = false;
            for ( var iCobertura = 0 ; iCobertura < coberturas.length ; iCobertura++ ) {
                if ( coberturas[iCobertura].numcobertura.value == cobertura.numcobertura.value ) {
                    coberturaEncontrada = true;
                    // Modificado por petición de Arra&Claud, antes de la modificación de las condiciones contractuales con sempsa
                    //gramos[iCobertura] += bolsa.grsbrutosfino.value * 0.90;
                    gramos[iCobertura] += (bolsa.grsbrutos.value * cobertura.ley.value);
                }
            }
            if ( !coberturaEncontrada ) {
                var index = coberturas.length;
                importes[index] = cobertura.preciogramofino.value;
                 // Modificado por petición de Arra&Claud, antes de la modificación de las condiciones contractuales con sempsa
                //gramos[index] = bolsa.grsbrutosfino.value * 0.90;
                gramos[index] = bolsa.grsbrutos.value * cobertura.ley.value;
                coberturas[index] = cobertura;
            }
        }
        for (var iCob = 0 ; iCob < coberturas.length; iCob++) {
            var linea = bean.lineasserviciosfacturascli.newChild();
            linea.idservicio.value = idServicioCobertura;
            linea.idimpuesto.value = beanServicio.idimpuestoventa.value;
            linea.iva.value = beanServicio.impuestosventa.father.iva.value;
            linea.tipoiva.value = beanServicio.tipoiva.value;
            // En horas pondremos los gramos
            linea.horas.value = gramos[iCob];
            linea.importeunitario.value = importes[iCob];
            linea.idexpedicion.value = expedicion.id.value;
            linea.idcobertura.value = coberturas[iCob].id.value;
            linea.descripcion.value = "Oro fino procedente de mi cuenta de pesos correspondientes a la operación " + coberturas[iCob].numcobertura.value;
        }
    }
    this.actualizarDistribucionIngresos();
    bean.aerpCalcularImpuestos.call();
}

DBRecordDlg.prototype.actualizarServicioFundiciones = function()
{
    var beanServicio = AERPScriptCommon.bean("servicios", "idempresa=" + AERPScriptCommon.envVar("idempresa") + " and codigointernoservicio='FUNDICIÓN'");
    if ( beanServicio == undefined || beanServicio == null ) {
        AERPMessageBox.warning("El sistema no tiene un servicio configurado para almacenar las fundiciones");
        return;
    }
    var idServicioFundicion = beanServicio.id.value;
    for (var i = 0 ; i < bean.lineasserviciosfacturascli.items.length ; i++) {
        if ( bean.lineasserviciosfacturascli.items[i].dbState != BaseBean.TO_BE_DELETED && 
             bean.lineasserviciosfacturascli.items[i].idservicio.value == idServicioFundicion ) {
            bean.lineasserviciosfacturascli.items[i].dbState = BaseBean.TO_BE_DELETED;
        }
    }
    for (var i = 0 ; i < bean.alepherp_informe_fundicion.items.length ; i++) {
        var linea = bean.lineasserviciosfacturascli.newChild();
        linea.idservicio.value = idServicioFundicion;
        linea.idimpuesto.value = beanServicio.idimpuestoventa.value;
        linea.iva.value = beanServicio.impuestosventa.father.iva.value;
        linea.tipoiva.value = beanServicio.tipoiva.value;
        // En horas pondremos los gramos
        linea.horas.value = bean.alepherp_informe_fundicion.items[i].peso_fundido.value;
        linea.importeunitario.value = bean.alepherp_informe_fundicion.items[i].alepherp_coberturas.father.preciogramo.value;;
        linea.descripcion.value = "Fundicion de joyas usadas y destruidas con contenido de oro superior a 325 milesimas, para su utilización como aleación semielaborada de oro";
    }
    this.actualizarDistribucionIngresos();
    bean.aerpCalcularImpuestos.call();
}

DBRecordDlg.prototype.actualizarDistribucionIngresos = function()
{
    var total = 0;
    var resumen = new Array();
    
    for (var i = 0 ; i < bean.alepherp_expediciones.items.length ; i++) {
        var expedicion = bean.alepherp_expediciones.items[i];
        
        for (var iBolsa = 0 ; iBolsa < expedicion.alepherp_informe_analisis_bolsas.items.length ; iBolsa++ ) {
            var bolsa = expedicion.alepherp_informe_analisis_bolsas.items[iBolsa];
            var lote = bolsa.alepherp_lotes.father;
            var tiendaEncontrada = false;
            total += lote.grs_brutos_tienda.value;                
            for ( var iTienda = 0 ; iTienda < resumen.length ; iTienda++ ) {
                if ( resumen[iTienda].tienda == lote.alepherp_tienda.father.nombre.value ) {
                    resumen[iTienda].brutos += lote.grs_brutos_tienda.value;
                    tiendaEncontrada = true;
                }
            }
            if ( !tiendaEncontrada ) {
                var dato = {
                    "tienda": lote.alepherp_tienda.father.nombre.value,
                    "brutos": lote.grs_brutos_tienda.value,
                    "idsubcentro": lote.alepherp_tienda.father.idsubcentrocoste.value,
                    "idcentro": lote.alepherp_tienda.father.subcentroscoste.father.centroscoste.father.id.value,
                    "nombrecentro": lote.alepherp_tienda.father.subcentroscoste.father.centroscoste.father.nombre.value,
                    "nombresubcentro": lote.alepherp_tienda.father.subcentroscoste.father.nombre.value
                };
                resumen[resumen.length] = dato;
            }
        }
    }
    // Ahora creamos las lineas de costes.
    for (var i = 0 ; i < resumen.length ; i++) {
        if ( resumen[i].idcentro > 0 && resumen[i].idsubcentro > 0 ) {
            var linea = bean.lineasdistribucioncostesfacturascli.newChild();
            linea.idcentro.value = resumen[i].idcentro;
            linea.idsubcentro.value = resumen[i].idsubcentro;
            linea.nombrecentro.value = resumen[i].nombrecentro;
            linea.nombresubcentro.value = resumen[i].nombresubcentro;
            linea.porcentaje.value = resumen[i].brutos / total * 100;
            linea.importe.value = linea.porcentaje.value * bean.neto.value / 100;
            linea.total.value = linea.porcentaje.value * bean.total.value / 100;
        }
    }
}
