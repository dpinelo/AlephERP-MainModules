/**
Cálculo de las líneas de IVA para documentos
*/
alepherp.generarLineasIva = function(bean, tablaIva, detalles) 
{
    // Vamos a hacer un algoritmo sencillo: Por defecto, tendremos un objeto con tantas propiedades como impuestos haya vigente.
    // Por cada propiedad de impuesto (IVA21, IVA10...) tendremos 6 líneas de iva: Deducible y no deducible, y una según si está Sujeta a I.V.A, exenta o no sujeta.
    try {
        // En este objeto iremos creando propiedades por cada impuesto que encontremos
        var lineasIva = { };
        var relationIva = bean.relation(tablaIva);
        relationIva.deleteAllChildren();
        for (var i = 0 ; i < detalles.length ; i++ ) {
            var detalle = detalles[i];
            // ¿Se ha agregado ya alguna línea perteneciente a este impuesto (IVA 21, IVA 10...)
            if ( !lineasIva.hasOwnProperty(detalle.idimpuesto.value) ) {
                lineasIva[detalle.idimpuesto.value] = [];
            }
            var nombreLinea = "";
            var tipoOperacionIva = "Deducible";
            if ( detalle.hasOwnProperty("tipooperacioniva") ) {
                tipoOperacionIva = detalle.tipooperacioniva.value;
            }
            nombreLinea = tipoOperacionIva + detalle.tipoiva.value;
            if ( !lineasIva[detalle.idimpuesto.value].hasOwnProperty(nombreLinea) ) {
                lineasIva[detalle.idimpuesto.value][nombreLinea] = relationIva.newChild();
                AERPCopyBeanFields(detalle, lineasIva[detalle.idimpuesto.value][nombreLinea]);
                if ( detalle.hasOwnProperty("tipooperacioniva") ) {
                    lineasIva[detalle.idimpuesto.value][nombreLinea].observaciones.value = tipoOperacionIva + " - " + detalle.tipoiva.value;
                } else {
                    lineasIva[detalle.idimpuesto.value][nombreLinea].observaciones.value = detalle.tipoiva.value;
                }
            }
            if ( detalle.tipoiva.value == "Sujeta a I.V.A." ) {
                lineasIva[detalle.idimpuesto.value][nombreLinea].neto.value += detalle.importetotal.value;
                lineasIva[detalle.idimpuesto.value][nombreLinea].iva.value = detalle.iva.value;
            } else if ( detalle.tipoiva.value == "Exenta de I.V.A." ) {
                lineasIva[detalle.idimpuesto.value][nombreLinea].neto.value += detalle.importetotal.value;
                lineasIva[detalle.idimpuesto.value][nombreLinea].iva.value = detalle.iva.value * -1;
            } else {
                lineasIva[detalle.idimpuesto.value][nombreLinea].neto.value += detalle.importetotal.value;            
                lineasIva[detalle.idimpuesto.value][nombreLinea].iva.value = 0;
            }
            if ( !detalle.incluirrecargoequivalencia.value ) {
                lineasIva[detalle.idimpuesto.value][nombreLinea].recargo.value = 0;
            }
        }
        // Para las facturas exentas, añadimos ahora la línea de no excención
        var lineasActuales = relationIva.items;
        for (var i=0 ; i < lineasActuales.length ; i++) {
            if ( (lineasActuales[i].dbState == BaseBean.INSERT || lineasActuales[i].dbState == BaseBean.UPDATE) && lineasActuales[i].tipoiva.value == "Exenta de I.V.A." ) {
                var lineaExenta = lineasActuales[i];
                var lineaSujeta = relationIva.newChild();
                lineaSujeta.tipoiva.value = "Sujeta a I.V.A.";
                lineaSujeta.idimpuesto.value = lineaExenta.idimpuesto.value; 
                lineaSujeta.neto.value = lineaExenta.neto.value;
                lineaSujeta.iva.value = lineaExenta.iva.value * -1; 
                lineaSujeta.observaciones.value = lineaSujeta.tipoiva.value;
            }
        }
    }
    catch(err) {
    
    }   
}

