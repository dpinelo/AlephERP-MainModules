/** Este script debe devolver un objeto, para que se adaptable al registro al que se asociarán las funciones. Ese objeto será
el registro (bean) sobre el que se aplicarán estas funciones. */
({

/** 
 * Verifica si el efecto actual debe ser marcado como pagado. Esta función se llama antes de guardar el efecto
 * para así tener actualizado siempre el estado del mismo. 
 */
aerpComprobarPagadoCobrado: function() {
    if ( this.metadata.tableName == "efectospago" ) {
        if ( this.importepagado.value >= this.importe.value ) {
            this.estado.value = "Pagado";
        } else {
            if ( this.pagosdevoluciones.items.length == 1 && this.pagosdevoluciones.items[0].tipo.value == "Devolución" ) {
                this.estado.value = "Devuelto";
            } else {
                this.estado.value = "Emitido";
            }
        }
    } else if ( this.metadata.tableName == "efectoscobro" ) {
        if ( this.importecobrado.value >= this.importe.value ) {
            this.estado.value = "Cobrado";
        } else {
            if ( this.cobrosdevoluciones.items.length == 1 && this.cobrosdevoluciones.items[0].tipo.value == "Devolución" ) {
                this.estado.value = "Devuelto";
            } else {
                this.estado.value = "Emitido";
            }
        }
    }
    return true;
},

/** 
  * Establece el recibo actual como pagado de forma rápida. Lo hace con la forma de pago pasada como parámetro.
  * Crea además el movimiento de pago (en caja o banco)
  */
aerpMarcarPagado: function(formaPago, fecha) {
    // Evitamos crear pagos vacíos
    if ( !AERPScriptCommon.equalsWithAllowedError(this.importe.value, this.importepagado.value, 1) ) {
        var resto = Number(this.importe.value) - Number(this.importepagado.value);
        var pago = this.pagosdevoluciones.newChild();
        pago.copyValues(this, "tasaconv", "coddivisa", "idcuenta", "idtarjeta", "idcaja");
        pago.importe.value = resto;
        pago.tipo.value = "Pago";
        pago.idformapago.value = formaPago.id.value;
        if ( isValidDate(fecha) ) {
            pago.fecha.value = fecha;
        } else {
            pago.fecha.value = new Date();
        }
        pago.descripcion.value = "Abono efecto de pago " + this.codigo.value + ": " + this.texto.value;
        pago.aerpCopyDatosFormaPago.call();
        if ( pago.idcuenta.value > 0 ) {
            pago.copyValues(formaPago.cuentasbanco.father, "iban", "codentidad", "codsucursal", "dc", "cuenta");
        }
        if ( this.empresas.father.contintegrada.value ) {
            pago.aerpGenerarAsiento.call();
        }
        pago.aerpCrearOActualizarMovimientoDinerario.call(fecha);
        this.estado.value = "Pagado";
        if ( !isValidDate(this.fechav.value) ) {
            if ( isValidDate(fecha) ) {
                this.fechav.value = fecha;
            } else {
                this.fechav.value = new Date();
            }
        }
        if ( this.idformapagoprevista.value == 0 ) {
            this.idformapagoprevista.value = formaPago.id.value;
        }
    }
},

/** 
  * Marca el efecto como cobrado, creando para ello el movimiento de pago ( y su correspondiente movimiento de caja o banco ) 
  */
aerpMarcarCobrado: function(formaPago, fecha) {
    // Evitamos crear cobros vacíos
    if ( !AERPScriptCommon.equalsWithAllowedError(this.importe.value, this.importecobrado.value, 1) ) {
        var resto = Number(this.importe.value) - Number(this.importecobrado.value);
        var cobro = this.cobrosdevoluciones.newChild();
        cobro.copyValues(this, "tasaconv", "coddivisa", "idcuenta", "idtarjeta", "idcaja");
        cobro.importe.value = resto;
        cobro.tipo.value = "Cobro";
        cobro.idformapago.value = formaPago.id.value;
        if ( isValidDate(fecha) ) {
            cobro.fecha.value = fecha;
        } else {
            cobro.fecha.value = new Date();
        }
        cobro.aerpCopyDatosFormaPago.call();
        if ( cobro.idcuenta.value > 0 ) {
            cobro.copyValues(formaPago.cuentasbanco.father, "iban", "codentidad", "codsucursal", "dc", "cuenta");
        }
        if ( this.empresas.father.contintegrada.value ) {
            cobro.aerpGenerarAsiento.call();
        }
        cobro.aerpCrearOActualizarMovimientoDinerario.call(fecha);
        this.estado.value = "Cobrado";
        if ( !isValidDate(this.fechav.value) ) {
            if ( isValidDate(fecha) ) {
                this.fechav.value = fecha;
            } else {
                this.fechav.value = new Date();
               }
        }
        if ( this.idformapagoprevista.value == 0 ) {
            this.idformapagoprevista.value = formaPago.id.value;
        }
    }
},

/** 
  * Marca el efecto como cobrado o pagado (dependiendo del tipo que sea) con la forma de pago prevista o seleccionada.
  * Internamente llamará a las funciones aerpMarcarPagado o aerpMarcarCobrado.
  */
aerpMarcarPagadoCobrado: function(fecha) {
    var fechaPago = new Date();
    if ( !(this.idformapagoprevista.value > 0) ) {
        return;
    }
    if ( isValidDate(fecha) && fecha != undefined && fecha != null ) {
        fechaPago = fecha;
    }
    if ( !isValidDate(this.fechav.value) ) {
        this.fechav.value = new Date();
    }
    if ( this.estado.value == "Pagado" && this.metadata.tableName == "efectospago" ) {
        this.aerpMarcarPagado.call(this.formaspago.father, fechaPago);
    } else if ( this.estado.value == "Cobrado" && this.metadata.tableName == "efectoscobro" ) {
        this.aerpMarcarCobrado.call(this.formaspago.father, fechaPago);
    }
},

/**
  * Marca para ser borrados todas aquellas entradas de tesorería (bancos o cajas) asociados a este efecto
  */
aerpBorrarMovimientosTesoreria: function() {
    var entradas = new Array;
    if ( this.metadata.tableName == "efectospago" ) {
        for (var i = 0 ; i < this.pagosdevoluciones.items.length ; i++) {
            var entradasbanco = this.pagosdevoluciones.items[i].getRelatedElementsByRelatedTableName("entradasbanco");
            var entradascaja = this.pagosdevoluciones.items[i].getRelatedElementsByRelatedTableName("entradascaja");
            for ( var j = 0 ; j < entradasbanco.length ; j++ ) {
                entradas[entradas.length] = entradasbanco[j];
            }
            for ( var j = 0 ; j < entradascaja.length ; j++ ) {
                entradas[entradas.length] = entradascaja[j];
            }
        }
    } else if ( this.metadata.tableName == "efectoscobro" ) {
        for (var i = 0 ; i < this.cobrosdevoluciones.items.length ; i++) {
            var entradasbanco = this.cobrosdevoluciones.items[i].getRelatedElementsByRelatedTableName("entradasbanco");
            var entradascaja = this.cobrosdevoluciones.items[i].getRelatedElementsByRelatedTableName("entradascaja");
            for ( var j = 0 ; j < entradasbanco.length ; j++ ) {
                entradas[entradas.length] = entradasbanco[j];
            }
            for ( var j = 0 ; j < entradascaja.length ; j++ ) {
                entradas[entradas.length] = entradascaja[j];
            }
        }
    }
    if ( entradas.length > 0 ) {
        for (var i = 0 ; i < entradas.length ; i++) {
            entradas[i].relatedBean.dbState = BaseBean.TO_BE_DELETED;
        }
    }
}

})
