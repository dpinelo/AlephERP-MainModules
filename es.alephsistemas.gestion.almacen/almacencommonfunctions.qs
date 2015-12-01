/** Este script debe devolver un objeto, para que se adaptable al registro al que se asociarán las funciones. Ese objeto será
el registro (bean) sobre el que se aplicarán estas funciones. */
({

/**
   Calcula por aproximación rápida el stock actual
*/
aerpCalcularStockActual: function(stock, offset) {
    if ( stock.articulos.father.trazabilidad == true ) {
        stock.cantidad.value = AERPScriptCommon.sqlCount("articulosinstancias", "idubicacion=" + stock.idubicacion.value + " and idarticulo=" + stock.idarticulo.value) + offset;
    } else {
        stock.cantidad.value = stock.cantidad.value + offset;
    }
},

/** 
    Recalcula los stocks actuales
*/
aerpRecalcularStock: function(stock, offset) {
    // Recalculamos el stock para cada artículo.
    // Tenemos que hacer el cálculo de los items que existen, en función del tipo de trazabilidad del artículo
    if ( stock.articulos.father.controlstock.value == false ) {
        return;
    }
    var iOffset = offset;
    if ( offset === undefined || offset == 0 ) {
        iOffset = 0;
    }
    if ( stock.articulos.father.trazabilidad.value ) {
        // Tenemos que buscar las existencias actuales simplemente por la trazabilidad
        if ( stock.articulos.father.dbState == BaseBean.INSERT ) {
            stock.cantidad.value = stock.articulos.father.articulosinstancias.items.length + iOffset;
        } else {
            stock.cantidad.value = AERPScriptCommon.sqlCount("articulosinstancias", "idarticulo=" + stock.idarticulo.value + " and debaja=false") + iOffset;
        }
    } else {
        // En este caso, tenemos que hacer un conteo de entradas
        var entradas = AERPScriptCommon.sqlSelect("select sum(si.cantidad) as c from stocksmovimientosinstancias as si, stocksmovimientos as st where si.idmovimiento=st.id and si.idarticulo=" 
                + stock.idarticulo.value + " and st.tipo='Entrada' and st.idubicaciondestino=" + stock.idubicacion.value);
        var salidas = AERPScriptCommon.sqlSelect("select sum(si.cantidad) as c from stocksmovimientosinstancias as si, stocksmovimientos as st where si.idmovimiento=st.id and si.idarticulo=" 
                + stock.idarticulo.value + " and st.tipo='Salida' and st.idubicacionorigen=" + stock.idubicacion.value);
        var transferenciassalida = AERPScriptCommon.sqlSelect("select sum(si.cantidad) as c from stocksmovimientosinstancias as si, stocksmovimientos as st where si.idmovimiento=st.id and si.idarticulo=" 
                + stock.idarticulo.value + " and st.tipo='Transferencias' and st.idubicacionorigen=" + stock.idubicacion.value);
        var transferenciasentradas = AERPScriptCommon.sqlSelect("select sum(si.cantidad) as c from stocksmovimientosinstancias as si, stocksmovimientos as st where si.idmovimiento=st.id and si.idarticulo=" 
                + stock.idarticulo.value + " and st.tipo='Transferencias' and st.idubicaciondestino=" + stock.idubicacion.value);
        var regularizacionesorigen = AERPScriptCommon.sqlSelect("select sum(si.cantidad) as c from stocksmovimientosinstancias as si, stocksmovimientos as st where si.idmovimiento=st.id and si.idarticulo=" 
                + stock.idarticulo.value + " and st.tipo='Regularización' and st.idubicacionorigen=" + stock.idubicacion.value);
        var regularizacionesdestino = AERPScriptCommon.sqlSelect("select sum(si.cantidad) as c from stocksmovimientosinstancias as si, stocksmovimientos as st where si.idmovimiento=st.id and si.idarticulo=" 
                + stock.idarticulo.value + " and st.tipo='Regularización' and st.idubicaciondestino=" + stock.idubicacion.value);
        stock.cantidad.value = new Number(entradas[0].c) - new Number(salidas[0].c) - new Number(transferenciassalida[0].c) + 
                               new Number(transferenciasentradas[0].c) + new Number(regularizacionesdestino[0].c) -
                               new Number(regularizacionesorigen[0].c) + iOffset;
        stock.fechaultreg.value = new Date();
    }
},

/**
Indica si la línea en concreto de albarán o factura, genera movimiento 
*/
aerpLineaGeneraMovimiento: function(linea) {
    // Generan movimientos de stock aquellas líneas de albarán de proveedores, o de facturas de proveedores que no provienen de un albarán previo.
    var generamovimiento = false;
    if ( linea.generamovimientosstock.value == true && linea.articulos.father.controlstock.value == true) {
        if ( linea.metadata.tableName == "lineasarticulosalbaranescli" || linea.metadata.tableName == "lineasarticulosalbaranesprov" ) {
            generamovimiento = true;
        }
        if ( (linea.metadata.tableName == "lineasarticulosfacturascli" || linea.metadata.tableName == "lineasarticulosfacturasprov") && linea.idlineaalbaran.value == 0 ) {
            generamovimiento = true;
        }
    }
    return generamovimiento;
},

/** 
    Genera el movimiento de stock de entrada, a partir de un albarán o factura. Esta función se llamará
    siempre desde la inserción, ya que la modificación es más compleja.
*/
aerpGenerarEntradaStock: function() {
    var lineas = this["lineasarticulos" + this.metadata.tableName].items;
    // Vamos a borrar los posibles movimientos de stocks que hubiese
    var category = "Movimientos de Stocks";
    var oldMovimientos = this.getRelatedElementsByCategory(category);
    for ( var i = 0 ; i < oldMovimientos.length ; i++ ) {
        this.deleteRelatedElement(oldMovimientos[i]);
    }
    this.deleteRelatedElementByCategory(category);
    for ( var i = 0 ; i < lineas.length ; i++ ) {
        if ( this.aerpLineaGeneraMovimiento.call(lineas[i]) ) {
            // En documentosgestion.tableTemp, se encuentran definidas las reglas de creación de nuevos elementos relacionados, que le darán valor
            // a este elemento relacionado.
            // Lo primero es ver si tenemos el stock creado para este artículo
            if ( lineas[i].idarticulo.value > 0 && lineas[i].idubicacion.value > 0 ) {
                var cantidad = 0;
                if ( this.deabono.value ) {
                    cantidad = lineas[i].cantidad.value * -1;
                } else {
                    cantidad = lineas[i].cantidad.value;
                }
                var stock = AERPScriptCommon.bean("stocks", lineas[i].idarticulo.sqlEqual + " AND " + lineas[i].idubicacion.sqlEqual + " AND idempresa=" + AERPScriptCommon.envVar("idempresa"));
                var hasToRecalculateStock = false;
                if ( stock === undefined ) {
                    stock = AERPScriptCommon.createBean("stocks");
                    stock.articulos.father = lineas[i].articulos.father;
                    stock.almacenes.father = lineas[i].almacenes.father;
                    stock.cantidad.value = cantidad;
                } else {
                    this.aerpCalcularStockActual.call(stock, cantidad);
                    hasToRecalculateStock = true;
                }
                
                AERPScriptCommon.addToTransaction(stock, this.actualContext);
                // Hacemos esto para forzar el recálculo del stock
                stock.touch();
                
                var element = this.newRelatedElement("stocksmovimientos", category);
                var stockmovimiento = element.relatedBean;
                
                stockmovimiento.tipo.value = "Entrada";
                stockmovimiento.fecha.value = this.fecha.value;
                stockmovimiento.almacendestino.father = lineas[i].almacenes.father;
                
                if ( !this.deabono.value ) {
                    if ( this.metadata.tableName == "albaranesprov" ) {
                        stockmovimiento.descripcion.value = "Entrada de material desde proveedor a través de albarán";
                    } else if (this.metadata.tableName == "facturasprov") {
                        stockmovimiento.descripcion.value = "Entrada de material desde proveedor a través de factura";
                    }
                } else {
                    if ( this.metadata.tableName == "albaranesprov" ) {
                        stockmovimiento.descripcion.value = "Abono de Entrada de material desde proveedor a través de albarán";
                    } else if (this.metadata.tableName == "facturasprov") {
                        stockmovimiento.descripcion.value = "Abono de Entrada de material desde proveedor a través de factura";
                    }
                }
                
                // Ahora generamos todas y cada unas de las instancias de articulos
                if ( !this.deabono.value ) {
                    if ( lineas[i].articulos.father.trazabilidad.value == true ) {
                        for (var iInstancia = 0 ; iInstancia < lineas[i].cantidad.value ; iInstancia++) {
                            var articuloInstancia = lineas[i].articulos.father.articulosinstancias.newChild();
                            articuloInstancia.almacenes.father = lineas[i].almacenes.father;
                            var stockInstancia = stockmovimiento.stocksmovimientosinstancias.newChild();
                            stockInstancia.articulos.father = lineas[i].articulos.father;
                            stockInstancia.articulosinstancias.father = articuloInstancia;
                        }
                    } else {
                        var stockInstancia = stockmovimiento.stocksmovimientosinstancias.newChild();
                        stockInstancia.articulos.father = lineas[i].articulos.father;
                        stockInstancia.cantidad.value = lineas[i].cantidad.value;
                    }
                }
                if ( hasToRecalculateStock ) {
                    this.aerpRecalcularStock.call(stock, lineas[i].cantidad);
                }
            }
        }
    }
},

/** 
    Borra el movimiento de stock de entrada, a partir de un albarán o factura. Esta función se llamará
    siempre desde el borrado del albarán, ya que la modificación es más compleja.
    Comprobará además si los artículos tienen trazabilidad, y de ser así, se borran las instancias no utilizadas.
*/
aerpBorrarEntradaStock: function() {
    var category = "Movimientos de Stocks";
    var oldMovimientos = this.getRelatedElementsByCategory(category);
    
    var lineas = this["lineasarticulos" + this.metadata.tableName].items;
    for ( var iLinea = 0 ; iLinea < lineas.length ; iLinea++ ) {
        if ( this.aerpLineaGeneraMovimiento.call(lineas[iLinea]) ) {
            if ( lineas[iLinea].articulos.father.trazabilidad.value == true ) {
                for ( var i = 0 ; i < oldMovimientos.length ; i++ ) {
                    var stockmovimiento = oldMovimientos[i].relatedBean;
                    for ( var iInstancia = 0 ; iInstancia < stockmovimiento.stocksmovimientosinstancias.items.length ; iInstancia++ ) {
                        if ( stockmovimiento.stocksmovimientosinstancias.items[iInstancia].idinstancia.value > 0 ) {
                            var otrosMovimientos = AERPScriptCommon.sqlSelect("select count(si.*) as c from stocksmovimientosinstancias as si, stocksmovimientos as st where si.idmovimiento=st.id and " +
                                "si.idinstancia=" + stockmovimiento.stocksmovimientosinstancias.items[iInstancia].idinstancia.value + " and st.tipo<>'Entrada'");
                            if ( new Number(otrosMovimientos[0].c) == 0 ) {
                                stockmovimiento.stocksmovimientosinstancias.items[iInstancia].articulosinstancias.father.dbState = BaseBean.TO_BE_DELETED;
                            }
                        }
                    }
                }
            }
            var stock = AERPScriptCommon.bean("stocks", "idarticulo=" + lineas[iLinea].idarticulo.value + " and idubicacion=" + lineas[iLinea].idubicacion.value);
            if ( stock != undefined ) {
                AERPScriptCommon.addToTransaction(stock, this.actualContext);
                if ( this.deabono.value ) {
                    this.aerpRecalcularStock.call(stock, lineas[iLinea].cantidad.value);
                } else {
                    this.aerpRecalcularStock.call(stock, -1 * lineas[iLinea].cantidad.value);
                }
            }
        }
    }
},

/** 
    Genera el movimiento de stock de salida, a partir de un albarán o factura. Esta función se llamará
    siempre desde la inserción, ya que la modificación es más compleja.
*/
aerpGenerarSalidaStock: function() {
    var lineas = this["lineasarticulos" + this.metadata.tableName].items;
    // Vamos a borrar los posibles movimientos de stocks que hubiese
    var category = "Movimientos de Stocks";
    var oldMovimientos = this.getRelatedElementsByCategory(category);
    for ( var i = 0 ; i < oldMovimientos.length ; i++ ) {
        this.deleteRelatedElement(oldMovimientos[i]);
    }
    this.deleteRelatedElementByCategory(category);
    // Debemos tener tantos movimientos de stocks como almacenes origen de artículos tengamos
    var idubicacionesorigen = new Array();
    var movimientosstock = new Array();
    var idx = 0;
    // Lo primero que vamos a hacer es obtener todos los almacenes orígenes de los artículos, y creamos un movimiento de stock por cada almacén origen.
    for ( var i = 0 ; i < lineas.length ; i++ ) {
        if ( this.aerpLineaGeneraMovimiento.call(lineas[i]) ) {
            if ( idubicacionesorigen.indexOf(lineas[i].idubicacion.value) == -1 ) {
                idubicacionesorigen[idx] = lineas[i].idubicacion.value;
                movimientosstock[idx] = this.newRelatedElement("stocksmovimientos", category);
                var stockmovimiento = movimientosstock[idx].relatedBean;
                stockmovimiento.tipo.value = "Salida";
                stockmovimiento.fecha.value = this.fecha.value;
                stockmovimiento.idubicacionorigen.value = lineas[i].idubicacion.value;
                
                if ( !this.deabono.value ) {
                    if ( this.metadata.tableName == "albaranescli" ) {
                        stockmovimiento.descripcion.value = "Salida de material por albarán emitido";
                    } else if (this.metadata.tableName == "facturascli") {
                        stockmovimiento.descripcion.value = "Salida de material por factura emitida";
                    }
                } else {
                    if ( this.metadata.tableName == "albaranescli" ) {
                        stockmovimiento.descripcion.value = "Abono de Salida de material por albarán emitido";
                    } else if (this.metadata.tableName == "facturascli") {
                        stockmovimiento.descripcion.value = "Abono de Salida de material por factura emitida";
                    }
                }
            }
        }
    }
    // Ahora, por cada movimiento de stock, vamos a ir añadiendo los artículos
    for (var i = 0 ; i < movimientosstock.length ; i++) {
        for (var iLinea = 0 ; iLinea < lineas.length ; iLinea++) {
            if ( this.aerpLineaGeneraMovimiento.call(lineas[iLinea]) ) {
                if ( lineas[iLinea].idubicacion.value == movimientosstock[i].relatedBean.idubicacionorigen.value ) {
                    var stockInstancia = movimientosstock[i].relatedBean.stocksmovimientosinstancias.newChild();
                    stockInstancia.articulos.father = lineas[iLinea].articulos.father;
                    if ( !this.deabono.value ) {
                        if ( lineas[iLinea].articulos.father.trazabilidad.value == true ) {
                            stockInstancia.articulosinstancias.father = lineas[iLinea].articulosinstancias.father;
                            stockInstancia.cantidad.value = 1;
                            lineas[iLinea].articulosinstancias.father.debaja.value = true;
                            lineas[iLinea].articulosinstancias.father.idubicacion.value = 0;
                        } else {
                            stockInstancia.cantidad.value = lineas[iLinea].cantidad.value;
                        }
                    } else {
                        stockInstancia.cantidad.value = -1 * lineas[iLinea].cantidad.value;
                    }
                }
                var stock = AERPScriptCommon.bean("stocks", "idarticulo=" + lineas[iLinea].idarticulo.value + " and idubicacion=" + lineas[iLinea].idubicacion.value);
                if ( stock != undefined ) {
                    AERPScriptCommon.addToTransaction(stock, this.actualContext);
                    this.aerpRecalcularStock.call(stock, -1 * lineas[iLinea].cantidad.value);
                }                
            }
        }
    }
},

/** 
    Borra la salida de stock de entrada, a partir de un albarán o factura. Esta función se llamará
    siempre desde el borrado del albarán, ya que la modificación es más compleja.
    Comprobará además si los artículos tienen trazabilidad, y de ser así, se borran las instancias no utilizadas.
*/
aerpBorrarSalidaStock: function() {
    var category = "Movimientos de Stocks";
    var oldMovimientos = this.getRelatedElementsByCategory(category);
    
    var lineas = this["lineasarticulos" + this.metadata.tableName].items;
    for ( var iLinea = 0 ; iLinea < lineas.length ; iLinea++ ) {
        if ( this.aerpLineaGeneraMovimiento.call(lineas[iLinea]) ) {
            if ( lineas[iLinea].articulos.father.trazabilidad.value == true ) {
                for ( var i = 0 ; i < oldMovimientos.length ; i++ ) {
                    var stockmovimiento = oldMovimientos[i].relatedBean;
                    for ( var iInstancia = 0 ; iInstancia < stockmovimiento.stocksmovimientosinstancias.items.length ; iInstancia++ ) {
                        // Si es un artículo trazable, debemos volver a darlo de alta, y buscar el almacén en el que estaba
                        if ( stockmovimiento.stocksmovimientosinstancias.items[iInstancia].articulos.father.trazabilidad.value == true ) {
                            var otrosMovimientos = AERPScriptCommon.sqlSelect("select st.idubicaciondestino as idubicaciondestino from stocksmovimientosinstancias as si, stocksmovimientos as st where si.idmovimiento=st.id and " +
                                "si.idinstancia=" + stockmovimiento.stocksmovimientosinstancias.items[iInstancia].idinstancia.value + " and st.tipo<>'Salida' order by st.fecha limit 1");
                            if ( new Number(otrosMovimientos[0].idubicaciondestino) > 0 ) {
                                stockmovimiento.stocksmovimientosinstancias.items[iInstancia].articulosinstancias.father.idubicacion.value = otrosMovimientos[0].idubicaciondestino;
                                stockmovimiento.stocksmovimientosinstancias.items[iInstancia].articulosinstancias.father.debaja.value = false;
                            }
                        }
                    }
                }
            }
            var stock = AERPScriptCommon.bean("stocks", "idarticulo=" + lineas[iLinea].idarticulo.value + " and idubicacion=" + lineas[iLinea].idubicacion.value);
            if ( stock != undefined ) {
                if ( !this.deabono.value ) {
                    AERPScriptCommon.addToTransaction(stock, this.actualContext);
                    this.aerpRecalcularStock.call(stock, lineas[iLinea].cantidad.value);
                }
            }                
        }
    }
}

})
