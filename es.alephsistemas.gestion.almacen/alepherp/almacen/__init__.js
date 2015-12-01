__setupPackage__("alepherp.almacen");

alepherp.almacen = {};

alepherp.almacen.articuloOInstanciaPorReferencia = function(referencia)
{
    var articulo = null, instancia = null;
    var isInstancia = true;
    var records = AERPScriptCommon.sqlSelect("select articulosinstancias.id from articulosinstancias, articulos where articulosinstancias.idarticulo=articulos.id and articulos.idempresa=" + 
            AERPScriptCommon.envVar("idempresa") + " and articulosinstancias.referencia='" + referencia + "'");
    if ( records == null || records.length == 0 ) {
        // Probemos a ver si hay un artículo con esa referencia
        var records = AERPScriptCommon.sqlSelect("select id from articulos where idempresa=" + 
            AERPScriptCommon.envVar("idempresa") + " and referencia='" + referencia + "'");
        if ( records == null || records.length == 0 ) {
            AERPScriptCommon.fadeMessage("No existe ningún artículo con esa referencia.");
            return;
        }
        isInstancia = false;
    }
    if ( isInstancia ) {
        instancia = AERPScriptCommon.bean("articulosinstancias", "id=" + records[0].id);
        articulo = instancia.articulos.father;
    } else {
        articulo = AERPScriptCommon.bean("articulos", "id=" + records[0].id);
    }
    var result = { 
            isInstancia: isInstancia, 
            articulo: articulo, 
            instancia: instancia 
            };
    return result;
}

/**
Comprueba si es posible dar de baja un artículo del stock a través de una venta
*/
alepherp.almacen.esPosibleSalidaArticulo = function(articulo, idubicacion)
{
    var mensaje = "";
    if ( articulo != null ) {
        if ( articulo.metadata.tableName == "articulosinstancias" ) {
           if ( articulo.debaja.value == true ) {
               mensaje = "Esta referencia ha sido dada de baja de esta empresa.";
           } else if ( articulo.idubicacion.value != idubicacion ) {
               mensaje = "Esta referencia está inventariada en un almacén diferente.";
           }
        } else {
            // Vamos a obtener el stock
            var stock = AERPScriptCommon.bean("stocks", "idarticulo=" + articulo.id.value + " and idubicacion=" + idubicacion );
            if ( stock == undefined || stock == null ) {
                mensaje = "Este artículo no está inventariado.";
            }
            if ( stock.cantidad.value <= 0 ) {
                mensaje = "Según el actual inventario, no hay existencias de este artículo.";
            }
        }
    }
    return mensaje;
}

/**
Recalcula todo el stock existente a partir de los movimientos en el sistema 
*/
alepherp.almacen.recalcularStocks = function() 
{
    var stocks = AERPScriptCommon.beans("stocks", "", "");
    AERPScriptCommon.showProgressDialog("Recalculando stocks...", stocks.length);
    for (var i = 0 ; i < stocks.length; i++ ) {
        var stock = stocks[i];
        AERPScriptCommon.addToTransaction(stock);
        if ( stock.articulos.father.trazabilidad.value ) {
            // Tenemos que buscar las existencias actuales simplemente por la trazabilidad
            stock.cantidad.value = AERPScriptCommon.sqlCount("articulosinstancias", "idarticulo=" + stock.idarticulo.value + " and debaja=false");
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
                                   new Number(regularizacionesorigen[0].c);
        }
        AERPScriptCommon.commit();
        AERPScriptCommon.setValueProgressDialog(i);
    }
    AERPScriptCommon.closeProgressDialog();
}
