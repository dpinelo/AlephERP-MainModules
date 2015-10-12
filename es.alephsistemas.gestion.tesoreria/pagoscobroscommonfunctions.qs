/** Este script debe devolver un objeto, para que se adaptable al registro al que se asociarán las funciones. Ese objeto será
el registro (bean) sobre el que se aplicarán estas funciones. */
({

/** Esta función crea el registro de entrada en caja, o en banco asociado al cobro o pago realizado */
aerpCrearOActualizarMovimientoDinerario: function(fecha) {
    // Obtengamos el elemento relacionado
    var relatedElementsBanco = this.getRelatedElementsByRelatedTableName("entradasbanco");
    var relatedElementsCaja = this.getRelatedElementsByRelatedTableName("entradascaja");
    var entrada = null;
    var signo = 1;
    var fechaMovimiento = new Date();
    if ( fecha != null && fecha != undefined ) {
        fechaMovimiento = fecha;
    }
    
    if (this.idformapago.value > 0 ) {
        if (this.formaspago.father.idcuenta.value > 0) {
            if ( relatedElementsBanco.length == 0 ) {
                entrada = this.newRelatedElement("entradasbanco").relatedBean;
            } else {
                entrada = relatedElementsBanco[0].relatedBean;
            }
            entrada.idcuentabanco.value = this.formaspago.father.idcuenta.value;
            if ( relatedElementsCaja.length > 0 ) {
                for (var i = 0 ; i < relatedElementsCaja.length ; i++) {
                    this.deleteRelatedElement(relatedElementsCaja[i]);
                }
            }
        } else if ( this.formaspago.father.idcaja.value > 0) {
            if ( relatedElementsCaja.length == 0 ) {
                entrada = this.newRelatedElement("entradascaja").relatedBean;
            } else {
                entrada = relatedElementsCaja[0].relatedBean;
            }
            entrada.idcaja.value = this.formaspago.father.idcaja.value;
            if ( relatedElementsBanco.length > 0 ) {
                for (var i = 0 ; i < relatedElementsBanco.length ; i++) {
                    this.deleteRelatedElement(relatedElementsBanco[i]);
                }
            }
        }
    }
    if ( entrada != null ) {
        entrada.fecha.value = fechaMovimiento;
        if ( this.metadata.tableName == "cobrosdevoluciones" ) {
            entrada.descripcion.value = "Cobro de Efecto de Cobro: " + this.efectoscobro.father.codigo.value + " del documento: " + this.efectoscobro.father.numdocumentointerno.value;
        } else if ( this.metadata.tableName == "pagosdevoluciones" ) {
            entrada.descripcion.value = "Pago de Efecto de Pago: " + this.efectospago.father.codigo.value + " del documento: " + this.efectospago.father.numdocumentotercero.value;
        }
        if ( this.tipo.value == "Pago" ) {
            entrada.tipo.value = "Salida";
            signo = -1;
        } else if ( this.tipo.value == "Cobro" ) {
            entrada.tipo.value ="Entrada";
            signo = 1;
        } else if ( this.tipo.value == "Devolución" ) {
            if ( this.metadata.tableName == "cobrosdevoluciones" ) {
                entrada.tipo.value = "Salida";
                signo = -1;
            } else if ( this.metadata.tableName == "pagosdevoluciones" ) {
                entrada.tipo.value = "Entrada";
                signo = 1;
            }
        }
        entrada.saldoinicial.value = 0;
        entrada.importe.value = signo * this.importedivisaempresa.value;
        entrada.saldofinal.value = signo * this.importedivisaempresa.value;
        
        // Veamos qué partida se corresponde a esta entrada en caja o banco
        var idsubcuenta = 0;
        if ( this.idcuenta.value > 0 ) {
            idsubcuenta = this.cuentasbanco.father.idsubcuenta.value;
        } else if ( this.idcaja.value > 0 ) {
            idsubcuenta = this.cajas.father.idsubcuenta.value;
        } else if ( this.idtarjeta.value > 0 ) {
            idsubcuenta = this.tarjetascredito.father.idsubcuenta.value;
        }
        if ( idsubcuenta > 0 ) {
            for (var i = 0 ; i < this.co_asientos.brother.co_partidas.items.length ; i++ ) {
                if ( this.co_asientos.brother.co_partidas.items[i].idsubcuenta.value == idsubcuenta ) {
                    entrada.co_partidas.brother = this.co_asientos.brother.co_partidas.items[i];
                }
            }
        }        
    }
},

/**
  * Cuando se escoge una forma de pago, se proporciona como valor de la cuenta, la caja o la tarjeta, el marcado en la forma 
  * de pago
  */
aerpCopyDatosFormaPago: function() {
    this.idcuenta.value = this.formaspago.father.idcuenta.value;
    this.idcaja.value = this.formaspago.father.idcaja.value;
    if ( this.metadata.tableName == "pagosdevoluciones" ) {
        this.idtarjeta.value = this.formaspago.father.idtarjeta.value;
    }
    if ( this.idcuenta.value > 0 ) {
        this.copyValues(this.formaspago.father.cuentasbanco.father, "iban", "codentidad", "codsucursal", "dc", "cuenta");
    } else {
        this.iban.value = "";
        this.codentidad.value = "";
        this.codsucursal.value = "";
        this.dc.value = "";
        this.cuenta.value = "";
    }    
}

})
