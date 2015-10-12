__setupPackage__("tesoreria");

/**
    Crea un efecto de pago para un bean, como por ejemplo, una factura de un proveedor. Para una mayor
    flexibilidad del sistema, los pagos se crearán como elementos relacionados (y no a través de relaciones
    directas)
*/
tesoreria.crearEfectosPago = function(bean) {
    var planPago = bean.father("planespago");
    var plazos = planPago.relationChilds("plazos", "dias asc");
    var tercero = bean.father("terceros");
    var direccion = bean.father("dirterceros");
    for ( var i = 0 ; i < plazos.length ; i++ ) {
        var efectoPago = bean.newRelationChild("efectospago");
        var importe = (bean.fieldValue("total") * plazos[i].fieldValue("aplazado"))/100
        efectoPago.setFieldValue("importe", importe);
        efectoPago.setFieldValue("fecha", bean.fieldValue("fecha"));
        var vencimiento = AERPScriptCommon.addIntervalToDate(
                 bean.fieldValue("fecha"), AERPScriptCommon.DAYS, plazos[i].fieldValue("dias"));
        efectoPago.setFieldValue("fechav", vencimiento);
        efectoPago.setFieldValue("numdocumento", bean.fieldValue("numproveedor"));
        efectoPago.setFieldValue("idtercero", bean.fieldValue("idtercero"));
        efectoPago.setFieldValue("nombretercero", tercero.fieldValue("nombre"));
        efectoPago.setFieldValue("cifnif", tercero.fieldValue("cifnif"));
        efectoPago.setFieldValue("importedivisaempresa", bean.fieldValue("totaldivisaempresa"));
        efectoPago.setFieldValue("coddivisa", bean.fieldValue("coddivisa"));
        efectoPago.setFieldValue("idcuenta", planPago.fieldValue(""));
        efectoPago.setFieldValue("descripcion", planPago.fieldValue("descripcion"));
        efectoPago.setFieldValue("iban", planPago.fieldValue("iban"));
        efectoPago.setFieldValue("codentidad", planPago.fieldValue("codentidad"));
        efectoPago.setFieldValue("codsucursal", planPago.fieldValue("codsucursal"));
        efectoPago.setFieldValue("dc", planPago.fieldValue("dc"));
        efectoPago.setFieldValue("cuenta", planPago.fieldValue("cuenta"));
          efectoPago.setFieldValue("iddirtercero", bean.fieldValue("iddirtercero"));
          efectoPago.setFieldValue("tasaconv", bean.fieldValue("tasaconv"));
          efectoPago.setFieldValue("coddivisa", bean.fieldValue("coddivisa"));
          if ( direccion != null )  {
               efectoPago.setFieldValue("direccion", direccion.fieldValue("direccion"));
            efectoPago.setFieldValue("codpostal", direccion.fieldValue("codpostal"));
            efectoPago.setFieldValue("poblacion", direccion.fieldValue("poblacion"));
               efectoPago.setFieldValue("provincia", direccion.fatherFieldValue("provincias", "provincia"));
               efectoPago.setFieldValue("codpais", direccion.fieldValue("codpais"));
           }
        if ( planPago.fieldValue("genrecibos") == "Pagados" ) {
            // Haciéndolo aquí, el pago cogerá automáticamente la tasaconv y coddivisa
            efectoPago.setFieldValue("estado", "Pagado");
/*            var pago = efectoPago.newRelationChild("pagosdevoluciones");
            pago.setFieldValue("importe", bean.fieldValue("importe"));
            pago.setFieldValue("tipo", "Pago");
            pago.setFieldValue("desdecaja", true);
            pago.setFieldValue("desdebaco", false);
        pago.save();*/
        } else {
            efectoPago.setFieldValue("estado", "Emitido");
        }           
           if ( efectoPago.save() ) {
               var relatedElement = bean.newRelatedElement(efectoPago, "Pagos");
               bean.saveRelatedElements();
           }
    }
}

