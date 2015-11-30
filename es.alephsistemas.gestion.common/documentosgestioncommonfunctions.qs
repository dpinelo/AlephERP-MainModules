/** Este script debe devolver un objeto, para que se adaptable al registro al que se asociarán las funciones. Ese objeto será
el registro (bean) sobre el que se aplicarán estas funciones. */
({

aerpTest: function(varAImprimir) {
   debug("Probando");
   debug("Probando " + varAImprimir);
},

/**
Para el ID Impuesto pasado, obtiene el período adecuado del mismo
*/
aerpObtenerIdPeriodoImpuesto: function(idimpuesto, fecha) {
    var fechaFormateada = fecha.getFullYear() + "-" + (fecha.getMonth()+1) + "-" + fecha.getDate();
    var sql = "select id from tvw_periodosimpuestos where fechadesde < '" + fechaFormateada + "' and fechahasta > '" + fechaFormateada + "' and idimpuesto=" + idimpuesto + " limit 1";
    var record = AERPScriptCommon.sqlSelectFirst(sql);
    if ( record != null && record != 0 ) {
        return record.id;
    }
    return 0;
},

/**
    Función para el cálculos de los impuestos de una determinada factura
*/
aerpCalcularImpuestos: function() {
    var lineas = [];
    var index = 0;
    for (var i = 0 ; i < this["lineasservicios" + this.metadata.tableName].items.length ; i++) {
        if ( this["lineasservicios" + this.metadata.tableName].items[i].dbState != BaseBean.TO_BE_DELETED && this["lineasservicios" + this.metadata.tableName].items[i].dbState != BaseBean.TO_BE_DELETED ) {
            lineas[index] = this["lineasservicios" + this.metadata.tableName].items[i];
            index++;
        }
    }
    for (var i = 0 ; i < this["lineasarticulos" + this.metadata.tableName].items.length ; i++) {
        if ( this["lineasarticulos" + this.metadata.tableName].items[i].dbState != BaseBean.TO_BE_DELETED && this["lineasarticulos" + this.metadata.tableName].items[i].dbState != BaseBean.TO_BE_DELETED ) {
            lineas[index] = this["lineasarticulos" + this.metadata.tableName].items[i];
            index++;
        }
    }
    this.aerpGenerarLineasIva.call("lineasiva" + this.metadata.tableName, lineas);
},

/**
    Cálculo de las líneas de IVA para documentos
*/
aerpGenerarLineasIva: function (tablaIva, detalles)  {
    // Vamos a hacer un algoritmo sencillo: Por defecto, tendremos un objeto con tantas propiedades como impuestos haya vigente.
    // Por cada propiedad de impuesto (IVA21, IVA10...) tendremos 6 líneas de iva: Deducible y no deducible, y una según si está Sujeta a I.V.A, exenta o no sujeta.
    try {
        // En este objeto iremos creando propiedades por cada impuesto que encontremos
        var lineasIva = [];
        var relationIva = this.relation(tablaIva);
        relationIva.deleteAllChildren();

        for (var i = 0 ; i < detalles.length ; i++ ) {
            var detalle = detalles[i];

            // Busquemos la linea de iva previa, si la hubiera
            var lineaIva = null;
            for ( var iLineaIva = 0 ; iLineaIva < relationIva.items.length ; iLineaIva++) {
                if ( relationIva.items[iLineaIva].dbState == BaseBean.INSERT || relationIva.items[iLineaIva].dbState == BaseBean.UPDATE ) {
                    if ( relationIva.items[iLineaIva].hasOwnProperty("tipooperacioniva") ) {
                        if ( relationIva.items[iLineaIva].idimpuesto.value == detalle.idimpuesto.value && 
                             relationIva.items[iLineaIva].tipoiva.value == detalle.tipoiva.value && 
                             relationIva.items[iLineaIva].tipooperacioniva.value == detalle.tipooperacioniva.value ) {
                            lineaIva = relationIva.items[iLineaIva];
                        }
                    } else {
                        if ( relationIva.items[iLineaIva].idimpuesto.value == detalle.idimpuesto.value && 
                            relationIva.items[iLineaIva].tipoiva.value == detalle.tipoiva.value ) {
                            lineaIva = relationIva.items[iLineaIva];
                        }
                    }
                }
            }
            // No la hay... la creamos
            if ( lineaIva == null ) {
                lineaIva = relationIva.newChild();
                AERPCopyBeanFields(detalle, lineaIva);
                if ( !detalle.incluirrecargoequivalencia.value ) {
                    lineaIva.recargo.value = 0;
                }
                if ( detalle.hasOwnProperty("tipooperacioniva") && detalle.tipoiva.value == "Sujeta a I.V.A." ) {
                    lineaIva.observaciones.value = detalle.tipooperacioniva.value + " - " + detalle.tipoiva.value;
                } else {
                    lineaIva.observaciones.value = detalle.tipoiva.value;
                }
            }
            lineaIva.neto.value += detalle.importetotal.value;
        }
    }
    catch(err) {
    }   
},

/** 
    Genera los efectos de pago o de cobro, según el plan de pagos, si los efectos están marcados para generación automática
*/
aerpGenerarEfectos: function() {
    if ( this.metadata.tableName == "facturasprov" && this.efectospagoautomaticos.value == false ) {
        return;
    } else if ( this.metadata.tableName == "facturascli" && this.efectoscobroautomaticos.value == false ) {
        return;
    }
    if ( ! (this.idplanpago.value > 0) ) {
        return;
    }
    if ( this.planespago.father.genrecibos.value == "No genera" ) {
        return;
    }
    var category, efecto;
    if ( this.metadata.tableName == "facturasprov" || this.metadata.tableName == "albaranesprov" ) {
        category = "Pagos";
        efecto = "efectospago";
    } else if ( this.metadata.tableName == "facturascli" || this.metadata.tableName == "albaranescli" ) {
        category = "Cobros";
        efecto = "efectoscobro";
    }
    var oldEfectos = this.getRelatedElementsByCategory(category);
    for ( var i = 0 ; i < oldEfectos.length ; i++ ) {
        if ( this.metadata.tableName == "facturasprov" && oldEfectos[i].relatedBean.metadata.tableName == "efectospago" ) {
            oldEfectos[i].relatedBean.dbState = BaseBean.TO_BE_DELETED;
            oldEfectos[i].relatedBean.aerpBorrarMovimientosTesoreria.call();
        } else if ( this.metadata.tableName == "facturascli" && oldEfectos[i].relatedBean.metadata.tableName == "efectoscobro" ) {
            oldEfectos[i].relatedBean.dbState = BaseBean.TO_BE_DELETED;
            oldEfectos[i].relatedBean.aerpBorrarMovimientosTesoreria.call();
        }
    }
    this.deleteRelatedElementByCategory(category);
    for ( var i = 0 ; i < this.planespago.father.plazos.items.length ; i++ ) {
        // En documentosgestion.tableTemp, se encuentran definidas las reglas de creación de nuevos elementos relacionados, que le darán valor
        // a este elemento relacionado.
        var element = this.newRelatedElement(efecto, category);
        element.relatedBean.estado.value = this.planespago.father.genrecibos.value;
        if ( this.planespago.father.plazos.items[i].cargodiafijomes.value == true ) {
            var vencimiento = new Date(this.fecha.value.getFullYear(), this.fecha.value.getMonth(), this.planespago.father.plazos.items[i].diames.value);
            element.relatedBean.fechav.value = vencimiento;
        } else {
            element.relatedBean.fechav.value = AERPScriptCommon.addIntervalToDate(this.fecha.value, AERPScriptCommon.DAYS, this.planespago.father.plazos.items[i].dias.value);
        }
        element.relatedBean.fecha.value = this.fecha.value;
        element.relatedBean.importe.value = this.total.value * this.planespago.father.plazos.items[i].aplazado.value / 100;
        element.relatedBean.idformapagoprevista.value = this.planespago.father.plazos.items[i].idformapago.value;
        if ( element.relatedBean.estado.value == "Pagado" ) {
            this.aerpMarcarPagada.call(this.planespago.father.plazos.items[i].formaspago.father, element.relatedBean.fechav.value);
        }
    }
},

/** 
    Marca como pagada la factura actual (o albarán). Para ello, crea el efecto de pago si no lo hubiera, y si lo hay, los marca como pagados 
*/
aerpMarcarPagada: function(formaPago, fecha) {
    var fechaPago = new Date();
    if ( fecha != null && fecha != undefined ) {
        fechaPago = fecha;
    }

    var efectos = new Array(), elements;
    
    // Vamos a agrupar todos los efectos de pago que tuviese este documento, para calcular cuál es el resto que queda por marcar como pagado.
    if ( this.metadata.tableName == "facturasprov" || this.metadata.tableName == "albaranesprov" ) {
        elements = this.getRelatedElementsByCategory("Pagos");
        if ( elements.length == 0 ) {
            // En las tablas, el script newRelatedElementScript se encarga de dar los valores adecuados.
            var element = this.newRelatedElement("efectospago", "Pagos");
            efectos[efectos.length] = element.relatedBean;
            if ( this.metadata.tableName == "albaranesprov" ) {
                element.addCategory("Albaranes");
            }
        } else {
            for (var i = 0 ; i < elements.length ;i++) { efectos[efectos.length]=elements[i].relatedBean; }
        }
    } else if ( this.metadata.tableName == "facturascli" || this.metadata.tableName == "albaranescli" ) {
        elements = this.getRelatedElementsByCategory("Cobros");
        if ( elements.length == 0 ) {
            // En las tablas, el script newRelatedElementScript se encarga de dar los valores adecuados.
            var element = this.newRelatedElement("efectoscobro", "Cobros");
            efectos[efectos.length] = element.relatedBean;
            if ( this.metadata.tableName == "albaranescli" ) {
                element.addCategory("Albaranes");
            }
        } else {
            for (var i = 0 ; i < elements.length ;i++) { efectos[efectos.length]=elements[i].relatedBean; }
        }
    }
   
    // El conjunto de efectos que hay, ¿suman el importe total del documento? Si no es así, habrá que crear un nuevo efecto con la diferencia
    var total = 0;
    for (var i = 0 ; i < efectos.length ; i++) {
        total += efectos[i].importe.value;
    }
    if ( !AERPScriptCommon.equalsWithAllowedError(total, this.total.value) ) {
        var element;
        if ( this.metadata.tableName == "facturasprov" || this.metadata.tableName == "albaranesprov" ) {
            // En las tablas, el script newRelatedElementScript se encarga de dar los valores adecuados.
            element = this.newRelatedElement("efectospago", "Pagos");
            efectos[efectos.length] = element.relatedBean;
        } else if ( this.metadata.tableName == "facturascli" || this.metadata.tableName == "albaranescli" ) {
            element = this.newRelatedElement("efectoscobro", "Cobros");
            efectos[efectos.length] = element.relatedBean;
        }
        element.relatedBean.importe.value = this.total.value - total;
        if ( this.metadata.tableName == "albaranesprov" || this.metadata.tableName == "albaranescli" ) {
            element.addCategory("Albaranes");
        }
    }
    
    for (var i = 0 ; i < efectos.length ; i++) {
        if ( this.metadata.tableName == "facturasprov" || this.metadata.tableName == "albaranesprov" ) {
            efectos[i].aerpMarcarPagado.call(formaPago, fecha);
        } else if ( this.metadata.tableName == "facturascli" || this.metadata.tableName == "albaranescli" ) {
            efectos[i].aerpMarcarCobrado.call(formaPago, fecha);
        }
    }
},

/**
Si es un pedido de proveedor, o pedido de cliente, y tiene marcado o se ha marcado el campo "generaalbaranautomatico", genera un albarán de cliente o proveedor
de forma automática. Por defecto, no creará las líneas de albarán, ya que éstas generan movimientos de stock, y todavía no se habrán producido.
*/
aerpGenerarAlbaranAutomatico: function() {
    if ( this.metadata.tableName != "pedidoscli" && this.metadata.tableName != "pedidosprov" ) {
        return;
    }
    var hayQueGenerarAlbaran = false;
    if ( this.dbState == BaseBean.INSERT && this.generaralbaranautomatico.value ) {
        hayQueGenerarAlbaran = true;
    } else if ( this.dbState == BaseBean.UPDATE && this.generaralbaranautomatico.value && !this.generaralbaranautomatico.oldValue ) {
        hayQueGenerarAlbaran = true;
    }
    if ( !hayQueGenerarAlbaran ) {
        return;
    }
    var albaran;
    if ( this.metadata.tableName == "pedidoscli" ) {
        albaran = this.albaranescli.newChild();
    } else if ( this.metadata.tableName == "pedidosprov" ) {
        albaran = this.albaranesprov.newChild();
    }
    albaran.copyValues(this, "tasaconv", "coddivisa", "codpais", "provincia", "ciudad", "codpostal", "direccion",
                             "nombredirtercero", "iddirtercero", "idtercero", "cifnif", "nombre", "idtarifa");
}

})
