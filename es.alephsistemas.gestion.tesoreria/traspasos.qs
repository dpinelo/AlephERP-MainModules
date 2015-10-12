/** Este script debe devolver un objeto, para que se adaptable al registro al que se asociarán las funciones. Ese objeto será
el registro (bean) sobre el que se aplicarán estas funciones. */
({

/**
 Genera los movimientos dinerarios (entradas en banco y/o caja correspondientes)
*/
aerpGenerarMovimientosDinerarios: function() {
    var elements = this.getRelatedElementsByCategory("Traspasos");
    for ( var i = 0 ; i < elements.length ; i++ ) {
        elements[i].relatedBean.dbState = BaseBean.TO_BE_DELETED;
    }
    this.deleteRelatedElementByCategory("Traspasos");
    var entradaOrigen = null, entradaDestino = null;
    
    var valid = false;
    
    if ( this.idcuentaorigen.value > 0 || this.idcajaorigen.value > 0 || this.idtarjetaorigen.value > 0 ) {
        valid = true;
    }
    if ( !valid ) {
        return;
    }
        
    if ( this.idcuentadestino.value > 0 || this.idcajadestino.value > 0 ) {
        valid = true;
    }
    if ( !valid ) {
        return;
    }
        
    
    if ( this.idcuentaorigen.value > 0 ) {
        entradaOrigen = this.newRelatedElement("entradasbanco", "Traspasos");
        entradaOrigen.relatedBean.idcuentabanco.value = this.idcuentaorigen.value;
    } else if ( this.idcajaorigen.value > 0 ) {
        entradaOrigen = this.newRelatedElement("entradascaja", "Traspasos");
        entradaOrigen.relatedBean.idcaja.value = this.idcajaorigen.value;
    } else if ( this.idtarjetaorigen.value > 0 ) {
        entradaOrigen = this.newRelatedElement("entradasbanco", "Traspasos");
        entradaOrigen.relatedBean.idcuentabanco.value = this.idtarjetaorigen.tarjetascredito.father.idcuenta.value;
    }
    if ( entradaOrigen == null ) {
        return;
    }
    entradaOrigen.relatedBean.fecha.value = this.fecha.value;
    entradaOrigen.relatedBean.tipo.value = "Salida";
    entradaOrigen.relatedBean.descripcion.value = "Traspaso " + this.codtraspaso.value;
    entradaOrigen.relatedBean.importe.value = -1 * this.importe.value;
    
    if ( this.idcuentadestino.value > 0 ) {
        entradaDestino = this.newRelatedElement("entradasbanco", "Traspasos");
        entradaDestino.relatedBean.idcuentabanco.value = this.idcuentadestino.value;
    } else if ( this.idcajadestino.value > 0 ) {
        entradaDestino = this.newRelatedElement("entradascaja", "Traspasos");
        entradaDestino.relatedBean.idcaja.value = this.idcajadestino.value;
    }
    if ( entradaDestino == null ) {
        return;
    }
    entradaDestino.relatedBean.fecha.value = this.fecha.value;
    entradaDestino.relatedBean.tipo.value = "Entrada";
    entradaDestino.relatedBean.descripcion.value = "Traspaso " + this.codtraspaso.value;
    entradaDestino.relatedBean.importe.value = this.importe.value;
}

})
