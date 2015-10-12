/** Este script debe devolver un objeto, para que se adaptable al registro al que se asociarán las funciones. Ese objeto será
el registro (bean) sobre el que se aplicarán estas funciones. */
({

/**************************************************************************************
    FUNCIONES AUXILIARES
***************************************************************************************/
    
/**
Esta función será aplicable sólo a ejercicios, y genera las cuentas especiales, necesarias para la creación y configuración automática de la contabilidad
*/
aerpGenerarCuentasEspeciales: function() {
    var datos = new Array (
        ["IVAREP","Cuenta de IVA repercutido","4770"],
        ["IVASOP","Cuenta de IVA soportado","4720"],
        ["IVARUE","Cuenta de IVA repercutido en adquisiciones intracomunitarias","4770"],
        ["IVASUE","Cuenta de IVA soportado en adquisiciones intracomunitarias","4720"],
        ["IVASIM","Cuenta de IVA soportado en importaciones","4720"],
        ["IVAEUE","Cuenta de IVA repercutido en entregas intracomunitarias","4770"],
        ["IVAREX","Cuenta de IVA repercutido para clientes exentos de IVA","4770"],
        ["IVARXP","Cuenta de IVA repercutido en exportaciones","4770"],
        ["IVAACR","Cuenta acreedoras de IVA en la regularización",""],
        ["IVADEU","Cuenta deudoras de IVA en la regularización",""],
        ["IVSISP","Cuenta de IVA soportado para Inversión de Sujeto Pasivo",""],
        ["IVRISP","Cuenta de IVA repercutido para Inversión de Sujeto Pasivo",""],
        ["PYG","Pérdidas y ganancias",""],
        ["PREVIO","Cuenta relativas al ejercicio previo",""],
        ["CAMPOS","Cuenta de diferencias positivas de cambio",""],
        ["CAMNEG","Cuenta de diferencias negativas de cambio",""],
        ["DIVPOS","Cuenta por diferencias positivas en divisa extranjera",""],
        ["EURPOS","Cuenta por diferencias positivas de conversión a la moneda local",""],
        ["EURNEG","Cuenta por diferencias negativas de conversión a la moneda local",""],
        ["CLIENT","Cuenta de clientes","4300"],
        ["PROVEE","Cuenta de proveedores y acreedores","4100"],
        ["COMPRA","Cuenta de compras","6000"],
        ["VENTAS","Cuenta de ventas","7000"],
        ["CAJA","Cuenta de caja","5700"],
        ["IRPFPR","Cuenta de retenciones para proveedores IRPFPR",""],
        ["IRPF","Cuenta de retenciones IRPF",""],
        ["GTORF","Gastos por recargo financiero",""],
        ["INGRF","Ingresos por recargo financiero",""],
        ["DEVCOM","Devoluciones de compras",""],
        ["DEVVEN","Devoluciones de ventas",""]
    );
    
    for (i = 0; i < datos.length; i++) {
        var cuentaEsp = this.co_cuentasesp.newChild();
        cuentaEsp.codigo.value = datos[i][0];
        cuentaEsp.descripcion.value = datos[i][1];
        if ( datos[i][2] != "" ) {
            var cuenta = AERPScriptCommon.bean("co_cuentas", "codcuenta='" + datos[i][2] + "' and idejercicio=" + this.id.value);
            if ( cuenta != undefined && cuenta != null ) {
                cuentaEsp.idcuenta.value = cuenta.id.value;
            }
            var subcuenta = AERPScriptCommon.bean("co_subcuentas", "codsubcuenta='" + AERPScriptCommon.leftJustified(datos[i][2], "0", 4 + this.longsubcuenta.value) + "' and idejercicio=" + this.id.value);
            if ( subcuenta != undefined && subcuenta != null ) {
                cuentaEsp.idsubcuenta.value = subcuenta.id.value;
            }
        }
    }
},

/** 
Devuelve la subcuenta contable que por defecto, tendrán las nuevas líneas de factura que se inserten.
El funcionamiento del sistema será:
1.- La línea comprobará qué serie de facturación tiene asociada la factura. Si esta tiene subcuenta contable por defecto,
se asignará esta a la nueva lína.
2.- Si no se cumple 1, cogerá la cuenta con código VENTAS o COMPRA de las cuentas por defecto definidas del sistema.
*/
aerpGetSubcuentaPorDefectoLineaFactura : function() {
    var facturaTableName, codigo;
    if ( this.metadata.tableName.indexOf("facturascli") > -1 ) {
        facturaTableName = "facturascli";
        codigo = "VENTAS";
    } else {
        facturaTableName = "facturasprov";
        codigo = "COMPRA";
    }
    if ( this[facturaTableName].father.seriesfacturacion.father.idsubcuenta.value > 0 ) {
        return this[facturaTableName].father.seriesfacturacion.father.idsubcuenta.value;
    }
    var cuentaEsp = AERPScriptCommon.bean("co_cuentasesp", "idejercicio=" + this[facturaTableName].father.idejercicio.value + " AND codigo='" + codigo + "'");
    if ( cuentaEsp != undefined ) {
        return cuentaEsp.idsubcuenta.value;
    }
    return 0;
},

aerpGetSubcuentaEspecial : function(codigo, idejercicio) {
    var cuentaEsp = AERPScriptCommon.bean("co_cuentasesp", "idejercicio=" + idejercicio + " AND codigo='" + codigo + "'");
    if ( cuentaEsp == undefined ) {
        AERPMessageBox("No es posible crear el asiento contable o el asiento será incorrecto. Las cuentas especiales no están definidas");
        return 0;
    }
    return cuentaEsp.idsubcuenta.value;
},

aerpGetNumAsiento: function(idejercicio) {
    var records = AERPScriptCommon.sqlSelectFirst("SELECT max(numero) as numero FROM co_asientos WHERE idejercicio=" + idejercicio);
    if ( records.numero == 0 ) {
        return 1;
    }
    return 0 + records.numero + 1;
},

aerpGetIdSubcuenta: function(codsubcuenta, idejercicio) {
    var beanSubcuenta = AERPScriptCommon.bean("co_subcuentas", "codsubcuenta='" + codsubcuenta + "' and idejercicio=" + idejercicio);
    if ( beanSubcuenta != null && beanSubcuenta != undefined ) {
        return beanSubcuenta.id.value;
    }
    return -1;
},

/**
Para las estructuras internas de datos que agrupan datos por subcuentas para las partidas, busca aquel objeto que pertenece a la partida indicada
*/
aerpGetPartidaPorSubcuenta: function (arrayDatos, idsubcuenta) {
    for (var i = 0 ; i < arrayDatos.length ; i++) {
        if ( arrayDatos[i].idsubcuenta == idsubcuenta ) {
            return i;
        }
    }
    return -1;
},



/**************************************************************************************
    GENERACIÓN DE ASIENTOS
***************************************************************************************/
/**
    Función que genera el asiento contable de una factura
*/
aerpGenerarAsiento: function() {
    if ( this.nogenerarasiento.value || (this.hasOwnProperty("seriesfacturacion") && this.seriesfacturacion.father.ignoracontabilidad.value) ) {
        var asiento = this.co_asientos.brother;
        if ( asiento != null ) {
            asiento.dbState = BaseBean.TO_BE_DELETED;
            asiento.touch();
        }    
        return;
    }
    if ( this.metadata.tableName == "facturasprov" && this.empresas.father.contintegrada.value ) {
        this.aerpGenerarAsientoFacturaRecibida.call();
    } else if ( this.metadata.tableName == "facturascli" && this.empresas.father.contintegrada.value  ) {
        this.aerpGenerarAsientoFacturaEmitida.call();
    } else if ( this.metadata.tableName == "cobrosdevoluciones" && this.efectoscobro.father.empresas.father.contintegrada.value  ) {
        this.aerpGenerarAsientoCobro.call();
    } else if ( this.metadata.tableName == "pagosdevoluciones" && this.efectospago.father.empresas.father.contintegrada.value ) {
        this.aerpGenerarAsientoPago.call();
    } else if ( this.metadata.tableName == "rrhh_nominas" && this.empresas.father.contintegrada.value ) {
        this.aerpGenerarAsientoNomina.call();
    }
},

aerpGenerarConceptoFacturaEmitida: function() {
    return "FE:" + this.codfactura.value + " " + this.nombre.value;
},

aerpGenerarAsientoFacturaEmitida: function ()  {
    var asiento = this.co_asientos.brother;
    if ( asiento == null ) {
        asiento = this.co_asientos.newChild();
    }    
    if ( asiento.dbState == BaseBean.INSERT ) {
        asiento.numero.value = this.aerpGetNumAsiento.call(this.idejercicio.value);
    } else {
        asiento.editable.value = true;
    }
    asiento.fecha.value = this.fecha.value;
    asiento.concepto.value = this.aerpGenerarConceptoFacturaEmitida.call();
    asiento.co_partidas.deleteAllChildren();
    asiento.editable.value = false;
    this.aerpGenerarPartidasFacturaEmitidaVenta.call(asiento);
    this.aerpGenerarPartidasFacturaEmitidaCliente.call(asiento);
    this.aerpGenerarPartidasFacturaEmitidaIVA.call(asiento);
    this.aerpGenerarPartidasFacturaEmitidaRecargo.call(asiento);
    this.aerpGenerarPartidasFacturaEmitidaIRPF.call(asiento);
},

/**
Recorre todas las línas de facturas, para recapitular todas las subcuentas de ventas de la factura
*/
aerpGenerarPartidasFacturaEmitidaVenta: function (asiento) {
    var partidasPorSubcuenta = new Array();
    var lineas = ["lineasserviciosfacturascli", "lineasarticulosfacturascli"];
    
    for (var lineType = 0 ; lineType < lineas.length ; lineType ++) {
        for (var i = 0 ; i < this[lineas[lineType]].items.length ; i++) {
            if ( this[lineas[lineType]].items[i].dbState == BaseBean.INSERT || this[lineas[lineType]].items[i].dbState == BaseBean.UPDATE ) {
                var idsubcuenta = this[lineas[lineType]].items[i].idsubcuenta.value;
                if ( idsubcuenta == 0 || idsubcuenta === undefined ) {
                    idsubcuenta = this.aerpGetSubcuentaEspecial.call("VENTAS", this.idejercicio.value);
                }
                var pos = this.aerpGetPartidaPorSubcuenta.call(partidasPorSubcuenta, idsubcuenta);
                var partida;
                if ( pos == -1 ) {
                    partida = new Object();
                    partida["idsubcuenta"] = idsubcuenta;
                    partida["importe"] = 0;
                    partidasPorSubcuenta[partidasPorSubcuenta.length] = partida;
                } else {
                    partida = partidasPorSubcuenta[pos];
                }
                partida["importe"] += this[lineas[lineType]].items[i].importetotal.value;
            }
        }
    }
    
    for (var i = 0 ; i < partidasPorSubcuenta.length ; i++) {
        var partida = asiento.co_partidas.newChild();
        partida.concepto.value = this.aerpGenerarConceptoFacturaEmitida.call();
        partida.idsubcuenta.value = partidasPorSubcuenta[i].idsubcuenta;
        partida.debe.value = 0;
        partida.haber.value += partidasPorSubcuenta[i].importe;
        if ( partida.idsubcuenta.value == 0 ) {
            AERPDebug("ERROR: aerpGenerarPartidasFacturaEmitidaVenta: Partida sin subcuenta en las líneas de servicios/artículos de las facturas emitidas");
        }
    }
},

aerpGenerarPartidasFacturaEmitidaCliente: function(asiento) {
    var idsubcuenta = this.terceros.father.idsubcuentacliente.value;
    if ( idsubcuenta == 0 || idsubcuenta === undefined ) {
        idsubcuenta = this.aerpGetSubcuentaEspecial.call('CLIENT', this.idejercicio.value);
    }
    var partida = asiento.co_partidas.newChild();
    partida.concepto.value = this.aerpGenerarConceptoFacturaEmitida.call();
    partida.idsubcuenta.value = idsubcuenta;
    partida.debe.value = this.total.value;
    partida.haber.value = 0;
    if ( partida.idsubcuenta.value == 0 ) {
        AERPDebug("ERROR: aerpGenerarPartidasFacturaEmitidaCliente: Partida sin subcuenta en el cliente de una factura emitida");
    }    
},

aerpGenerarPartidasFacturaEmitidaIVA: function(asiento) {
    for (var i = 0 ; i < this.lineasivafacturascli.items.length ; i++) {
        if ( (this.lineasivafacturascli.items[i].dbState == BaseBean.INSERT || this.lineasivafacturascli.items[i].dbState == BaseBean.UPDATE) && 
             (this.lineasivafacturascli.items[i].totaliva.value != 0 || this.lineasivafacturascli.items[i].tipoiva.value == "Inversión de sujeto pasivo") &&
              this.lineasivafacturascli.items[i].tipoiva.value != "No sujeta a I.V.A." ) {
            var partida = asiento.co_partidas.newChild();
            partida.concepto.value = this.aerpGenerarConceptoFacturaEmitida.call();
            partida.debe.value = 0;
            
            if ( this.lineasivafacturascli.items[i].tipoiva.value == "Inversión de sujeto pasivo" ) {
                partida.idsubcuenta.value = this.aerpGetSubcuentaEspecial.call("IVRISP", this.idejercicio.value);
                partida.haber.value = 0;
            } else {
                partida.haber.value = this.lineasivafacturascli.items[i].totaliva.value;
                var idsubcuenta = 0;
                if ( partida.haber.value >= 0 ) {
                    if ( this.lineasivafacturascli.items[i].idimpuesto.value > 0 && 
                          this.lineasivafacturascli.items[i].tvw_periodosimpuestos.father.idimpuesto.value > 0 && 
                          this.lineasivafacturascli.items[i].tvw_periodosimpuestos.father.impuestos.father.idsubcuentarep.value > 0 ) {
                              idsubcuenta = this.lineasivafacturascli.items[i].tvw_periodosimpuestos.father.impuestos.father.idsubcuentarep.value;
                    } else {
                        AERPDebug("ATENCIÓN: aerpGenerarPartidasFacturaEmitidaIVA: El impuesto " + this.lineasivafacturascli.items[i].idimpuesto.value + " no tiene definida una subcuenta válida de IVA repercutido. Se escogerá de las cuentas por defecto");
                    }
                    if ( idsubcuenta == 0 ) {
                        switch (this.terceros.father.regimeniva.value) {
                            case "U.E.": {
                                idsubcuenta = this.aerpGetSubcuentaEspecial.call("IVAEUE", this.idejercicio.value);
                                break;
                            }
                            case "Exento": {
                                idsubcuenta = this.aerpGetSubcuentaEspecial.call("IVAREX", this.idejercicio.value);
                                break;
                            }
                            case "Exportaciones": {
                                idsubcuenta = this.aerpGetSubcuentaEspecial.call("IVARXP", this.idejercicio.value);
                                break;
                            }
                            default: {
                                idsubcuenta = this.aerpGetSubcuentaEspecial.call("IVAREP", this.idejercicio.value);
                            }
                        }
                    }
                } else {
                    if ( this.lineasivafacturascli.items[i].idimpuesto.value > 0 && 
                          this.lineasivafacturascli.items[i].tvw_periodosimpuestos.father.idimpuesto.value > 0 && 
                          this.lineasivafacturascli.items[i].tvw_periodosimpuestos.father.impuestos.father.idsubcuentasop.value > 0 ) {
                              idsubcuenta = this.lineasivafacturascli.items[i].tvw_periodosimpuestos.father.impuestos.father.idsubcuentasop.value;
                    } else {
                        AERPDebug("ATENCIÓN: aerpGenerarPartidasFacturaEmitidaIVA: El impuesto " + this.lineasivafacturascli.items[i].idimpuesto.value + " no tiene definida una subcuenta válida de IVA soportado. Se escogerá de las cuentas por defecto");
                    }
                    
                    if ( idsubcuenta == 0 ) {
                        switch (this.terceros.father.regimeniva.value) {
                            case "U.E.": {
                                idsubcuenta = this.aerpGetSubcuentaEspecial.call("IVASUE", this.idejercicio.value);
                                break;
                            }
                            case "General": {
                                idsubcuenta = this.aerpGetSubcuentaEspecial.call("IVASOP", this.idejercicio.value);
                                break;
                            }
                            case "Agrario": {
                                idsubcuenta = this.aerpGetSubcuentaEspecial.call("IVASRA", this.idejercicio.value);
                                break;
                            }            
                            default: {
                                idsubcuenta = this.aerpGetSubcuentaEspecial.call("IVASOP", this.idejercicio.value);
                            }
                        }
                    }
                }
                partida.idsubcuenta.value = idsubcuenta;
                if ( partida.idsubcuenta.value == 0 ) {
                    AERPDebug("ERROR: aerpGenerarPartidasFacturaEmitidaIVA: Partida sin subcuenta en el IVA de una factura emitida");
                }                
            }
        }
    }
},

aerpGenerarPartidasFacturaEmitidaRecargo: function(asiento) {
    var haber = 0;
    for (var i = 0 ; i < this.lineasivafacturascli.items.length ; i++) {
        if ( this.lineasivafacturascli.items[i].dbState == BaseBean.INSERT || this.lineasivafacturascli.items[i].dbState == BaseBean.UPDATE ) {
            haber += this.lineasivafacturascli.items[i].totalrecargo.value;
        }
    }    
    if ( haber > 0 ) {
        var partida = asiento.co_partidas.newChild();
        partida.concepto.value = this.aerpGenerarConceptoFacturaEmitida.call();
        partida.debe.value = 0;
        partida.haber.value = haber;
        partida.idsubcuenta.value = this.aerpGetSubcuentaEspecial.call("IVARRE", this.idejercicio.value);
        if ( partida.idsubcuenta.value == 0 ) {
            AERPDebug("ERROR: aerpGenerarPartidasFacturaEmitidaRecargo: Partida sin subcuenta en el recargo de una factura emitida");
        }    
    }
},

aerpGenerarPartidasFacturaEmitidaIRPF: function(asiento) {
    for (var  i = 0 ; i < this.lineasserviciosfacturascli.items.length ; i++) {
        if ( (this.lineasserviciosfacturascli.items[i].dbState == BaseBean.INSERT || this.lineasserviciosfacturascli.items[i].dbState == BaseBean.UPDATE) && this.lineasserviciosfacturascli.items[i].irpf.value > 0 ) {
            var partida = asiento.co_partidas.newChild();
            partida.concepto.value = this.aerpGenerarConceptoFacturaEmitida.call();
            partida.haber.value = 0;
            partida.debe.value = this.lineasserviciosfacturascli.items[i].irpf.value * this.lineasserviciosfacturascli.items[i].importetotal.value / 100;
            
            var idsubcuenta = 0;
            if ( this.lineasserviciosfacturascli.items[i].idimpuesto_irpf.value > 0 && 
                  this.lineasserviciosfacturascli.items[i].tvw_periodosimpuestos_irpf.father.idimpuesto.value > 0 && 
                  this.lineasserviciosfacturascli.items[i].tvw_periodosimpuestos_irpf.father.impuestos.father.idsubcuentarep.value > 0 ) {
                      idsubcuenta =  this.lineasserviciosfacturascli.items[i].tvw_periodosimpuestos_irpf.father.impuestos.father.idsubcuentahpacr.value;
            }
            if ( idsubcuenta == 0 && 
                 this.lineasserviciosfacturascli.items[i].idservicio.value > 0 &&
                this.lineasserviciosfacturascli.items[i].servicios.father.idirpfventa.value > 0 ) {
                    idsubcuenta = this.lineasserviciosfacturascli.items[i].servicios.father.impuestos_irpf.father.idsubcuentahppagos.value;
            }
            if ( idsubcuenta == 0 ) {
                idsubcuenta = this.aerpGetSubcuentaEspecial.call("IRPF", this.idejercicio.value);
            }
            partida.idsubcuenta.value = idsubcuenta;
            if ( partida.idsubcuenta.value == 0 ) {
                AERPDebug("ERROR: aerpGenerarPartidasFacturaEmitidaIRPF: Partida sin subcuenta en el IRPF de una factura emitida");
            }    
        }
    }
},

aerpGenerarAsientoFacturaRecibida: function ()  {
    var asiento = this.co_asientos.brother;
    if ( asiento == null ) {
        asiento = this.co_asientos.newChild();
    }
    if ( asiento.dbState == BaseBean.INSERT ) {
        asiento.numero.value = this.aerpGetNumAsiento.call(this.idejercicio.value);
    } else {
        asiento.editable.value = true;
    }
    asiento.fecha.value = this.fecha.value;
    asiento.concepto.value = this.aerpGenerarConceptoFacturaRecibida.call();
    asiento.editable.value = false;
    asiento.co_partidas.deleteAllChildren();
    this.aerpGenerarPartidasFacturaRecibidaCompra.call(asiento);
    this.aerpGenerarPartidasFacturaRecibidaProveedor.call(asiento);
    this.aerpGenerarPartidasFacturaRecibidaIVA.call(asiento);
    this.aerpGenerarPartidasFacturaRecibidaRecargo.call(asiento);
    this.aerpGenerarPartidasFacturaRecibidaIRPF.call(asiento);    
},

aerpGenerarConceptoFacturaRecibida: function() {
    return "FR:" + this.numproveedor.value + " " + this.nombre.value;
},

/**
Recorre todas las línas de facturas, para recapitular todas las subcuentas de compras de la factura
*/
aerpGenerarPartidasFacturaRecibidaCompra: function (asiento) {
    var partidasPorSubcuenta = new Array();
    var lineas = ["lineasserviciosfacturasprov", "lineasarticulosfacturasprov"];
    
    for (var lineType = 0 ; lineType < lineas.length ; lineType ++) {
        for (var i = 0 ; i < this[lineas[lineType]].items.length ; i++) {
            if ( this[lineas[lineType]].items[i].dbState == BaseBean.INSERT || this[lineas[lineType]].items[i].dbState == BaseBean.UPDATE ) {
                var idsubcuenta = this[lineas[lineType]].items[i].idsubcuenta.value;
                if ( idsubcuenta == 0 || idsubcuenta === undefined ) {
                    idsubcuenta = this.aerpGetSubcuentaEspecial.call("COMPRA", this.idejercicio.value);
                }
                var pos = this.aerpGetPartidaPorSubcuenta.call(partidasPorSubcuenta, idsubcuenta);
                var partida;
                if ( pos == -1 ) {
                    partida = new Object();
                    partida["idsubcuenta"] = idsubcuenta;
                    partida["importe"] = 0;
                    partidasPorSubcuenta[partidasPorSubcuenta.length] = partida;
                } else {
                    partida = partidasPorSubcuenta[pos];
                }
                partida["importe"] += this[lineas[lineType]].items[i].importetotal.value;
            }
        }
    }
    
    for (var i = 0 ; i < partidasPorSubcuenta.length ; i++) {
        var partida = asiento.co_partidas.newChild();
        partida.concepto.value = this.aerpGenerarConceptoFacturaRecibida.call();
        partida.idsubcuenta.value = partidasPorSubcuenta[i].idsubcuenta;
        partida.debe.value = partidasPorSubcuenta[i].importe;
        partida.haber.value = 0;
        if ( partida.idsubcuenta.value == 0 ) {
            AERPDebug("ERROR: aerpGenerarPartidasFacturaRecibidaCompra: Partida sin subcuenta en los servicios/articulos de una factura recibida");
        }    
    }
},

aerpGenerarPartidasFacturaRecibidaProveedor: function(asiento) {
    var idsubcuenta = this.terceros.father.idsubcuentaproveedor.value;
    if ( idsubcuenta == 0 || idsubcuenta === undefined ) {
        idsubcuenta = this.aerpGetSubcuentaEspecial.call('PROVEE', this.idejercicio.value);
    }
    var partida = asiento.co_partidas.newChild();
    partida.concepto.value = this.aerpGenerarConceptoFacturaRecibida.call();
    partida.idsubcuenta.value = idsubcuenta;
    partida.debe.value = 0;
    partida.haber.value = this.total.value;
    if ( partida.idsubcuenta.value == 0 ) {
        AERPDebug("ERROR: aerpGenerarPartidasFacturaRecibidaProveedor: Partida sin subcuenta en el proveedor una factura recibida");
    }    
},

aerpGenerarPartidasFacturaRecibidaIVA: function(asiento) {
    /// No se introduce partida de IVA en facturas de importación. El IVA se cobra en la factura del transitario
    if ( this.terceros.father.regimeniva.value == "Importaciones" ) {
        return;
    }
    for (var i = 0 ; i < this.lineasivafacturasprov.items.length ; i++) {
        var lineaiva = this.lineasivafacturasprov.items[i];
        if ( (lineaiva.dbState == BaseBean.INSERT || lineaiva.dbState == BaseBean.UPDATE) && lineaiva.tipoiva.value != "No sujeta a I.V.A." ) {
            var partida = asiento.co_partidas.newChild();
            partida.concepto.value = this.aerpGenerarConceptoFacturaRecibida.call();
            partida.haber.value = 0;
            
            var idsubcuenta = 0;
            if ( lineaiva.tipoiva.value == "Inversión de sujeto pasivo" ) {
                idsubcuenta = this.aerpGetSubcuentaEspecial.call("IVSISP", this.idejercicio.value);
                partida.debe.value = 0;
            } else {
                partida.debe.value = lineaiva.totaliva.value;
                if ( partida.debe.value >= 0 ) {
                    if ( lineaiva.idimpuesto.value > 0 && 
                          lineaiva.tvw_periodosimpuestos.father.idimpuesto.value > 0 && 
                          lineaiva.tvw_periodosimpuestos.father.impuestos.father.idsubcuentasop.value > 0 ) {
                              idsubcuenta = lineaiva.tvw_periodosimpuestos.father.impuestos.father.idsubcuentasop.value;
                    }
                    
                    if ( idsubcuenta == 0 ) {
                        switch (this.terceros.father.regimeniva.value) {
                            case "U.E.": {
                                idsubcuenta = this.aerpGetSubcuentaEspecial.call("IVASUE", this.idejercicio.value);
                                break;
                            }
                            case "General": {
                                idsubcuenta = this.aerpGetSubcuentaEspecial.call("IVASOP", this.idejercicio.value);
                                break;
                            }
                            case "Agrario": {
                                idsubcuenta = this.aerpGetSubcuentaEspecial.call("IVASRA", this.idejercicio.value);
                                break;
                            }            
                            default: {
                                idsubcuenta = this.aerpGetSubcuentaEspecial.call("IVASOP", this.idejercicio.value);
                            }
                        }
                    }
                } else {
                    if ( lineaiva.idimpuesto.value > 0 && 
                          lineaiva.tvw_periodosimpuestos.father.idimpuesto.value > 0 && 
                          lineaiva.tvw_periodosimpuestos.father.impuestos.father.idsubcuentarep.value > 0 ) {
                              idsubcuenta = lineaiva.tvw_periodosimpuestos.father.impuestos.father.idsubcuentarep.value;
                    }
                    if ( idsubcuenta == 0 ) {
                        switch (this.terceros.father.regimeniva.value) {
                            case "U.E.": {
                                idsubcuenta = this.aerpGetSubcuentaEspecial.call("IVAEUE", this.idejercicio.value);
                                break;
                            }
                            case "Exento": {
                                idsubcuenta = this.aerpGetSubcuentaEspecial.call("IVAREX", this.idejercicio.value);
                                break;
                            }
                            case "Exportaciones": {
                                idsubcuenta = this.aerpGetSubcuentaEspecial.call("IVARXP", this.idejercicio.value);
                                break;
                            }
                            default: {
                                idsubcuenta = this.aerpGetSubcuentaEspecial.call("IVAREP", this.idejercicio.value);
                            }
                        }
                    }
                }
            }
            partida.idsubcuenta.value = idsubcuenta;
            if ( partida.idsubcuenta.value == 0 ) {
                AERPDebug("ERROR: aerpGenerarPartidasFacturaRecibidaIVA: Partida sin subcuenta en el IVA una factura recibida");
            }    
        }
    }
},

aerpGenerarPartidasFacturaRecibidaRecargo: function(asiento) {
    var debe = 0;
    for (var i = 0 ; i < this.lineasivafacturasprov.items.length ; i++) {
        if ( this.lineasivafacturasprov.items[i].dbState == BaseBean.INSERT || this.lineasivafacturasprov.items[i].dbState == BaseBean.UPDATE ) {
            debe += this.lineasivafacturasprov.items[i].totalrecargo.value;
        }
    }    
    if ( debe > 0 ) {
        var partida = asiento.co_partidas.newChild();
        partida.concepto.value = this.aerpGenerarConceptoFacturaRecibida.call();
        partida.debe.value = debe;
        partida.haber.value = 0;
        partida.idsubcuenta.value = this.aerpGetSubcuentaEspecial.call("GTORF", this.idejercicio.value);
        if ( partida.idsubcuenta.value == 0 ) {
            AERPDebug("ERROR: aerpGenerarPartidasFacturaRecibidaRecargo: Partida sin subcuenta en el recargo una factura recibida");
        }    
    }
},

aerpGenerarPartidasFacturaRecibidaIRPF: function(asiento) {
    for (var  i = 0 ; i < this.lineasserviciosfacturasprov.items.length ; i++) {
        if ( (this.lineasserviciosfacturasprov.items[i].dbState == BaseBean.INSERT || this.lineasserviciosfacturasprov.items[i].dbState == BaseBean.UPDATE) && this.lineasserviciosfacturasprov.items[i].irpf.value > 0 ) {
            var partida = asiento.co_partidas.newChild();
            partida.concepto.value = this.aerpGenerarConceptoFacturaRecibida.call();
            partida.debe.value = 0;
            partida.haber.value = this.lineasserviciosfacturasprov.items[i].irpf.value * this.lineasserviciosfacturasprov.items[i].importetotal.value / 100;
            
            var idsubcuenta = 0;
            if ( this.lineasserviciosfacturasprov.items[i].idimpuesto_irpf.value > 0 && 
                  this.lineasserviciosfacturasprov.items[i].tvw_periodosimpuestos_irpf.father.idimpuesto.value > 0 && 
                  this.lineasserviciosfacturasprov.items[i].tvw_periodosimpuestos_irpf.father.impuestos_irpf.father.idsubcuentahpacr.value > 0 ) {
                      idsubcuenta =  this.lineasserviciosfacturasprov.items[i].tvw_periodosimpuestos_irpf.father.impuestos_irpf.father.idsubcuentahpacr.value;
            }
            if ( idsubcuenta == 0 && 
                 this.lineasserviciosfacturasprov.items[i].idservicio.value > 0 &&
                 this.lineasserviciosfacturasprov.items[i].servicios.father.idirpfcompra.value > 0 ) {
                    idsubcuenta = this.lineasserviciosfacturasprov.items[i].servicios.father.impuestos_irpf.father.idsubcuentahpacr.value;
            }            
            if ( idsubcuenta == 0 ) {
                idsubcuenta = this.aerpGetSubcuentaEspecial.call("IRPF", this.idejercicio.value);
            }
            partida.idsubcuenta.value = idsubcuenta;
            if ( partida.idsubcuenta.value == 0 ) {
                AERPDebug("ERROR: aerpGenerarPartidasFacturaRecibidaIRPF: Partida sin subcuenta en el IRPF una factura recibida");
            }    
        }
    }
},

/**
Genera el asiento de un cobro de un efecto de pago 
*/
aerpGenerarAsientoCobro: function() {
    var idsubcuentadebe = 0;
    if ( this.idcaja.value > 0 && this.cajas.father.idsubcuenta.value > 0 ) {
        idsubcuentadebe = this.cajas.father.idsubcuenta.value;
    } else if ( this.idcuenta.value > 0 && this.cuentasbanco.father.idsubcuenta.value > 0 ) {
        idsubcuentadebe = this.cuentasbanco.father.idsubcuenta.value;
    } else if ( this.idtarjeta.value > 0 && this.tarjetascredito.father.idsubcuenta.value > 0 ) {
        idsubcuentadebe = this.tarjetascredito.father.idsubcuenta.value;
    } else if ( this.idformapago.value > 0 ) {
        if ( this.formaspago.father.idcaja.value > 0 && this.formaspago.father.cajas.father.idsubcuenta.value > 0 ) {
            idsubcuentadebe = this.formaspago.father.cajas.father.idsubcuenta.value ;
        } else if ( this.formaspago.father.idcuenta.value > 0 && this.formaspago.father.cuentasbanco.father.idsubcuenta.value > 0 ) {
            idsubcuentadebe = this.formaspago.father.cuentasbanco.father.idsubcuenta.value ;
        } else if ( this.formaspago.father.idtarjeta.value > 0 && this.formaspago.father.tarjetascredito.father.idsubcuenta.value > 0 ) {
            idsubcuentadebe = this.formaspago.father.tarjetascredito.father.idsubcuenta.value ;
        } 
    }
    if ( idsubcuentadebe == 0 ) {
        return;
    }
    var idsubcuentahaber = 0;
    if ( this.efectoscobro.father.idtercero.value > 0 ) {
        idsubcuentahaber = this.efectoscobro.father.terceros.father.idsubcuentacliente.value;
    }
    if ( idsubcuentahaber == 0 ) {
        idsubcuentahaber = this.aerpGetSubcuentaEspecial.call("CLIENT", this.efectoscobro.father.idejercicio.value);;
    }
    
    var asiento = this.co_asientos.brother;
    if ( asiento == null ) {
        asiento = this.co_asientos.newChild();
    }    
    if ( asiento.dbState == BaseBean.INSERT ) {
        asiento.fecha.value = this.fecha.value;
        asiento.numero.value = this.aerpGetNumAsiento.call(this.efectoscobro.father.idejercicio.value);
    } else {
        asiento.editable.value = true;
    }
    var concepto = "C: " + this.efectoscobro.father.codigo.value + ", D: " + this.efectoscobro.father.numdocumentointerno.value;
    asiento.concepto.value = concepto;
    asiento.co_partidas.deleteAllChildren();
    asiento.editable.value = false;
    
    var partida1 = asiento.co_partidas.newChild();
    partida1.concepto.value = concepto;
    partida1.debe.value = this.importe.value;
    partida1.haber.value = 0;
    partida1.idsubcuenta.value = idsubcuentadebe;

    var partida2 = asiento.co_partidas.newChild();
    partida2.concepto.value = concepto;
    partida2.debe.value = 0;
    partida2.haber.value = this.importe.value;
    partida2.idsubcuenta.value = idsubcuentahaber;
},

/**
Genera el asiento de pago de un efecto de pago 
*/
aerpGenerarAsientoPago: function() {
    var idsubcuentahaber = 0;
    if ( this.idcaja.value > 0 && this.cajas.father.idsubcuenta.value > 0 ) {
        idsubcuentahaber = this.cajas.father.idsubcuenta.value;
    } else if ( this.idcuenta.value > 0 && this.cuentasbanco.father.idsubcuenta.value > 0 ) {
        idsubcuentahaber = this.cuentasbanco.father.idsubcuenta.value;
    } else if ( this.idtarjeta.value > 0 && this.tarjetascredito.father.idsubcuenta.value > 0 ) {
        idsubcuentahaber = this.tarjetascredito.father.idsubcuenta.value;
    } else if ( this.idformapago.value > 0 ) {
        if ( this.formaspago.father.idcaja.value > 0 && this.formaspago.father.cajas.father.idsubcuenta.value > 0 ) {
            idsubcuentahaber = this.formaspago.father.cajas.father.idsubcuenta.value ;
        } else if ( this.formaspago.father.idcuenta.value > 0 && this.formaspago.father.cuentasbanco.father.idsubcuenta.value > 0 ) {
            idsubcuentahaber = this.formaspago.father.cuentasbanco.father.idsubcuenta.value ;
        } else if ( this.formaspago.father.idtarjeta.value > 0 && this.formaspago.father.tarjetascredito.father.idsubcuenta.value > 0 ) {
            idsubcuentahaber = this.formaspago.father.tarjetascredito.father.idsubcuenta.value ;
        } 
    }
    if ( idsubcuentahaber == 0 ) {
        return;
    }
    var idsubcuentadebe = 0;
    if ( this.efectospago.father.idtercero.value > 0 ) {
        idsubcuentadebe = this.efectospago.father.terceros.father.idsubcuentaproveedor.value;
    }
    if ( idsubcuentadebe == 0 ) {
        idsubcuentadebe = this.aerpGetSubcuentaEspecial.call("PROVEE", this.efectospago.father.idejercicio.value);;
    }
    
    var asiento = this.co_asientos.brother;
    if ( asiento == null ) {
        asiento = this.co_asientos.newChild();
    }    
    if ( asiento.dbState == BaseBean.INSERT ) {
        asiento.fecha.value = this.fecha.value;
        asiento.numero.value = this.aerpGetNumAsiento.call(this.efectospago.father.idejercicio.value);
    } else {
        asiento.editable.value = true;
    }
    var concepto = "P: " + this.efectospago.father.codigo.value + ", D: " + this.efectospago.father.numdocumentotercero.value;
    asiento.concepto.value = concepto;
    asiento.co_partidas.deleteAllChildren();
    asiento.editable.value = false;
    
    var partida1 = asiento.co_partidas.newChild();
    partida1.concepto.value = concepto;
    partida1.debe.value = 0;
    partida1.haber.value = this.importe.value;
    partida1.idsubcuenta.value = idsubcuentahaber;

    var partida2 = asiento.co_partidas.newChild();
    partida2.concepto.value = concepto;
    partida2.debe.value = this.importe.value;
    partida2.haber.value = 0;
    partida2.idsubcuenta.value = idsubcuentadebe;    
},

/**
Asientos de traspasos en tesorería
*/
aerpGenerarAsientoTraspaso: function() {
    var entradas = this.getRelatedElementsByCategory("Traspasos");
    var asiento = this.co_asientos.brother;
    if ( asiento == null ) {
        asiento = this.co_asientos.newChild();
    }    
    if ( asiento.dbState == BaseBean.INSERT ) {
        asiento.fecha.value = this.fecha.value;
        asiento.numero.value = this.aerpGetNumAsiento.call(this.idejercicio.value);
    } else {
        asiento.editable.value = true;
    }
    var concepto = "T: " + this.codtraspaso.value;
    asiento.concepto.value = concepto;
    asiento.co_partidas.deleteAllChildren();
    asiento.editable.value = false;

    if ( entradas.length == 0 ) {
        return;
    }
    
    for (var i = 0 ; i < entradas.length ; i++) {
        var idsubcuenta = 0;
        if ( entradas[i].relatedBean.metadata.tableName == "entradasbanco" ) {
            idsubcuenta = entradas[i].relatedBean.cuentasbanco.father.idsubcuenta.value;
        } else if ( entradas[i].relatedBean.metadata.tableName == "entradascaja" ) {
            idsubcuenta = entradas[i].relatedBean.cajas.father.idsubcuenta.value;
        }
        if ( idsubcuenta > 0 ) {
            var partida = asiento.co_partidas.newChild();
            partida.concepto.value = concepto;
            if ( entradas[i].relatedBean.tipo.value == "Entrada" ) {
                partida.debe.value = entradas[i].relatedBean.importe.value;
                partida.haber.value = 0;
            } else {
                var importe = entradas[i].relatedBean.importe.value > 0 ? entradas[i].relatedBean.importe.value : entradas[i].relatedBean.importe.value * -1;
                importe -= this.coste.value;
                partida.debe.value = 0;
                partida.haber.value = importe;
            }
            partida.idsubcuenta.value = idsubcuenta;
        }
    }
    if ( this.coste.value > 0 ) {
        var idsubcuenta = this.aerpGetSubcuentaEspecial.call("GTORF", this.idejercicio.value);
        if ( idsubcuenta > 0 ) {
            var partida = asiento.co_partidas.newChild();
            partida.concepto.value = concepto;
            partida.debe.value = 0;
            partida.haber.value = this.coste.value;
            partida.idsubcuenta.value = idsubcuenta;
        }
    }
},

/**
Genera el asiento contable de una nómina
*/
aerpGenerarAsientoNomina: function() {
    var asiento = this.co_asientos.brother;
    if ( asiento == null ) {
        asiento = this.co_asientos.newChild();
    }
    if ( asiento.dbState == BaseBean.INSERT ) {
        asiento.numero.value = this.aerpGetNumAsiento.call(this.idejercicio.value);
    } else {
        asiento.editable.value = true;
    }
    asiento.fecha.value = this.fecha.value;
    asiento.concepto.value = "N:" + this.nombreempleado.value;
    asiento.editable.value = false;
    asiento.co_partidas.deleteAllChildren();
    this.aerpGenerarPartidasNominaSueldoBruto.call(asiento);
    this.aerpGenerarPartidasNominaIRPF.call(asiento);
    this.aerpGenerarPartidasNominaSS.call(asiento);
    this.aerpGenerarPartidasNominaDietas.call(asiento);
    this.aerpGenerarPartidasNominaEmpleado.call(asiento);    
},

aerpGenerarPartidasNominaSueldoBruto: function(asiento) {
    var partida = asiento.co_partidas.newChild();
    partida.concepto.value = asiento.concepto.value;
    partida.debe.value = this.sueldobruto.value;
    partida.haber.value = 0;
    partida.idsubcuenta.value = this.aerpGetSubcuentaEspecial.call("GTORF", this.idejercicio.value);
},

aerpGenerarPartidasNominaIRPF: function(asiento) {
    var partida = asiento.co_partidas.newChild();
    partida.concepto.value = asiento.concepto.value;
    partida.debe.value = 0;
    partida.haber.value = this.irpf.value;
    partida.idsubcuenta.value = this.aerpGetSubcuentaEspecial.call("GTORF", this.idejercicio.value);
},

aerpGenerarPartidasNominaSS: function(asiento) {
    var partida = asiento.co_partidas.newChild();
    partida.concepto.value = asiento.concepto.value;
    partida.debe.value = 0;
    partida.haber.value = this.ss.value;
    partida.idsubcuenta.value = this.aerpGetSubcuentaEspecial.call("GTORF", this.idejercicio.value);
},

aerpGenerarPartidasNominaDietas: function(asiento) {
    var partida = asiento.co_partidas.newChild();
    partida.concepto.value = asiento.concepto.value;
    partida.debe.value = this.dietas.value;
    partida.haber.value = 0;
    partida.idsubcuenta.value = this.aerpGetSubcuentaEspecial.call("GTORF", this.idejercicio.value);
},

aerpGenerarPartidasNominaEmpleado: function(asiento) {
    var partida = asiento.co_partidas.newChild();
    partida.concepto.value = asiento.concepto.value;
    partida.debe.value = 0;
    partida.haber.value = this.apercibir.value;
    partida.idsubcuenta.value = this.aerpGetIdSubcuenta.call(this.alepherp_personal.father.codsubcuenta.value, this.idejercicio.value);
},

aerpGenerarPartidasFacturaRecibidaRecargo: function(asiento) {
    var debe = 0;
    for (var i = 0 ; i < this.lineasivafacturasprov.items.length ; i++) {
        if ( this.lineasivafacturasprov.items[i].dbState == BaseBean.INSERT || this.lineasivafacturasprov.items[i].dbState == BaseBean.UPDATE ) {
            debe += this.lineasivafacturasprov.items[i].totalrecargo.value;
        }
    }    
    if ( debe > 0 ) {
        var partida = asiento.co_partidas.newChild();
        partida.concepto.value = this.aerpGenerarConceptoFacturaRecibida.call();
        partida.debe.value = debe;
        partida.haber.value = 0;
        partida.idsubcuenta.value = this.aerpGetSubcuentaEspecial.call("GTORF", this.idejercicio.value);
    }
},

/**
Calcula el balance de situación, según la definición del mismo en co_balance, en la tabla buffer co_balance_buffer
*/
aerpGenerarBalance: function(fechainicial, fechafinal, includeCuentaDetail, includeSubcuentaDetail) {
    var resultado = {};
    
    var idejercicio = this.id.value;
    var balanceGenerado = new Array();
    var beans = new Array();
    var lineasBalance = AERPScriptCommon.beans("co_balance", "", "nivel ASC");
    var pyg = this.aerpGenerarPyG.call(fechainicial, fechafinal, includeCuentaDetail, includeSubcuentaDetail);
    var resultadoEjercicio = pyg[pyg.length - 1].importe;
    
    AERPScriptCommon.showProgressDialog("Generando balance de situación...", lineasBalance.length + 1);    
    
    // Lo primero, es borrar cualquier balance previo que se hubiese generado en el buffer
    AERPScriptCommon.sqlExecute("DELETE FROM co_balance_buffer WHERE idejercicio=" + idejercicio + 
            " AND fechainicial=" + AERPScriptCommon.sqlDate(fechainicial) + 
            " AND fechafinal=" + AERPScriptCommon.sqlDate(fechafinal));
    AERPScriptCommon.setValueProgressDialog(i);       
    
    for (var i = 0 ; i < lineasBalance.length ; i++) {
        var lineaBalance = lineasBalance[i];
        var entradaEnBalance = {
            nombre: lineaBalance.nombre.value, 
            nivel: lineaBalance.nivel.value, 
            naturaleza: lineaBalance.naturaleza.value,
            id: lineaBalance.id.value,
            cuentas: new Array(),
            subcuentas: new Array(),
            nivelresumen: lineaBalance.nivelresumen.value,
            nivelesResumen: lineaBalance.cuentas.value
        };
        if ( lineaBalance.cuentas.value != "" && !lineaBalance.nivelresumen.value ) {
            var importe = 0;
            var cuentas = lineaBalance.cuentas.value.split(",");
            for (var iCuenta = 0 ; iCuenta < cuentas.length ; iCuenta++) {
                var signo;
                if ( lineasBalance[i].naturaleza.value == "ACTIVO" ) {
                    signo = 1;
                } else {
                    signo = -1;
                }
                var cuenta = cuentas[iCuenta];
                if ( cuenta.indexOf("(") != -1 ) {
                    signo = signo * -1;
                    cuenta = cuenta.replace("(", "");
                    cuenta = cuenta.replace(")", "");
                }
                if ( cuenta == "rPyG" ) {
                    importe = resultadoEjercicio;
                } else {
                    var subcuentas = AERPScriptCommon.sqlSelect("SELECT sum(p.debe) as debe, sum(p.haber) as haber " +
                        "FROM co_partidas as p, co_asientos as a, co_subcuentas as s WHERE a.id=p.idasiento AND p.idsubcuenta=s.id AND a.idejercicio=" + idejercicio +
                        " AND a.fecha between " + AERPScriptCommon.sqlDate(fechainicial) + " AND " + AERPScriptCommon.sqlDate(fechafinal) + 
                        " AND s.codsubcuenta like '" + cuenta + "%'");
                    if ( subcuentas.length > 0 ) {
                        importe += signo * (subcuentas[0].debe - subcuentas[0].haber);
                        if ( includeCuentaDetail ) {
                            var cuentasDetail = AERPScriptCommon.sqlSelect("SELECT c.codcuenta, c.descripcion, sum(p.debe) as debe, sum(p.haber) as haber " +
                                "FROM co_partidas as p, co_asientos as a, co_subcuentas as s, co_cuentas as c WHERE a.id=p.idasiento AND p.idsubcuenta=s.id AND s.idcuenta = c.id AND a.idejercicio=" + idejercicio +
                                " AND a.fecha between " + AERPScriptCommon.sqlDate(fechainicial) + " AND " + AERPScriptCommon.sqlDate(fechafinal) + 
                                " AND c.codcuenta like '" + cuenta + "%' GROUP BY c.codcuenta, c.descripcion");
                            for ( var iDetail = 0 ; iDetail < cuentasDetail.length ; iDetail++ ) {
                                var lineaCuenta = { 
                                    codcuenta: cuentasDetail[iDetail].codcuenta,
                                    nombre: cuentasDetail[iDetail].descripcion,
                                    importe: signo * (cuentasDetail[iDetail].debe - cuentasDetail[iDetail].haber)
                                }
                                entradaEnBalance.cuentas.push(lineaCuenta);
                            }
                        }                    
                         if ( includeSubcuentaDetail ) {
                            var subcuentasDetail = AERPScriptCommon.sqlSelect("SELECT s.codsubcuenta, s.descripcion, sum(p.debe) as debe, sum(p.haber) as haber " +
                                "FROM co_partidas as p, co_asientos as a, co_subcuentas as s WHERE a.id=p.idasiento AND p.idsubcuenta=s.id AND a.idejercicio=" + idejercicio +
                                " AND a.fecha between " + AERPScriptCommon.sqlDate(fechainicial) + " AND " + AERPScriptCommon.sqlDate(fechafinal) + 
                                " AND s.codsubcuenta like '" + cuenta + "%' GROUP BY s.codsubcuenta, s.descripcion");
                            for ( var iDetail = 0 ; iDetail < subcuentasDetail.length ; iDetail++ ) {
                                var lineaSubcuenta = { 
                                    codsubcuenta: subcuentasDetail[iDetail].codsubcuenta,
                                    nombre: subcuentasDetail[iDetail].descripcion,
                                    importe: signo * (subcuentasDetail[iDetail].debe - subcuentasDetail[iDetail].haber)
                                }
                                entradaEnBalance.subcuentas.push(lineaSubcuenta);
                            }
                        }
                    }
                }
                entradaEnBalance.importe = importe;
            }
        }
        balanceGenerado.push(entradaEnBalance);
        AERPScriptCommon.setValueProgressDialog(i+1);               
    }
    
    for (var iNivel = 4 ; iNivel > 0 ; iNivel-- ) {
        for (var i = 0 ; i < balanceGenerado.length ; i++) {
            if ( balanceGenerado[i].nivel.length == iNivel && !balanceGenerado[i].hasOwnProperty("importe") ) {
                balanceGenerado[i].importe = this.aerpGenerarBalanceSubtotal.call(balanceGenerado, balanceGenerado[i].nivel);
            }
        }
    }

    this.aerpCalcularResumenBalance.call(balanceGenerado);
    
    for (var i = 0 ; i < balanceGenerado.length ; i++) {
        var beanLineaBalance = AERPScriptCommon.createBean("co_balance_buffer");
        beanLineaBalance.setOverwriteFieldValue("idejercicio", idejercicio);
        beanLineaBalance.idlineabalance.value = balanceGenerado[i].id;
        beanLineaBalance.fechainicial.value = fechainicial;
        beanLineaBalance.fechafinal.value = fechafinal;
        beanLineaBalance.importe.value = balanceGenerado[i].importe;
        beans.push(beanLineaBalance);
    }
    
    AERPScriptCommon.closeProgressDialog();
    resultado.balanceGenerado = balanceGenerado;
    resultado.beans = beans;
    resultado.pyg = pyg;
    return resultado;
},

aerpGenerarBalanceSubtotal: function(balance, nivel) {
    if (typeof String.prototype.startsWith != 'function') {
        String.prototype.startsWith = function (str){
            return this.indexOf(str) == 0;
        };
    }
    
    var importe = 0;
    for (var i = 0 ; i < balance.length ; i++) {
        if ( balance[i].nivel.startsWith(nivel) && balance[i].nivel != nivel && !balance[i].nivelresumen && balance[i].nivel.length == (nivel.length + 1) ) {
            importe += balance[i].importe;
        }
    }
    return importe;
},

aerpCalcularResumenBalance: function(balance) {
    for (var i = 0 ; i < balance.length ; i++) {
        if ( balance[i].nivelresumen ) {
            var importe = 0;
            var nivelesCalculo = balance[i].nivelesResumen.split(",");
            for (var iLinea = 0 ; iLinea < balance.length ; iLinea++) {
                if ( balance[i].id != balance[iLinea].id ) {
                    var idx = nivelesCalculo.indexOf(balance[iLinea].nivel);
                    if ( idx != -1 ) {
                        importe += balance[iLinea].importe;
                    }
                    idx = nivelesCalculo.indexOf("(" + balance[iLinea].nivel + ")");
                    if ( idx != -1 ) {
                        importe -= balance[iLinea].importe;
                    }
                }
            }
            balance[i].importe = importe;
        }
    }
},

/**
Calcula el balance de situación, según la definición del mismo en co_balance, en la tabla buffer co_balance_buffer
*/
aerpGenerarPyG: function(fechainicial, fechafinal, includeCuentaDetail, includeSubcuentaDetail) {
    var idejercicio = this.id.value;
    var pygGenerado = new Array();
    var beans = new Array();
    var lineasPyG = AERPScriptCommon.beans("co_pyg", "", "nivel ASC");
    AERPScriptCommon.showProgressDialog("Generando Pérdidas y Ganancias...", lineasPyG.length + 1);    
    
    // Lo primero, es borrar cualquier balance previo que se hubiese generado en el buffer
    AERPScriptCommon.sqlExecute("DELETE FROM co_pyg_buffer WHERE idejercicio=" + idejercicio + 
            " AND fechainicial=" + AERPScriptCommon.sqlDate(fechainicial) + 
            " AND fechafinal=" + AERPScriptCommon.sqlDate(fechafinal));
    AERPScriptCommon.setValueProgressDialog(i);       
    
    for (var i = 0 ; i < lineasPyG.length ; i++) {
        var lineaPyG = lineasPyG[i];
        var entradaEnPyG = {
            nombre: lineaPyG.nombre.value, 
            nivel: lineaPyG.nivel.value, 
            id: lineaPyG.id.value,
            cuentas: new Array(),
            subcuentas: new Array(),
            nivelresumen: lineaPyG.nivelresumen.value,
            nivelesResumen: lineaPyG.cuentas.value
        };
        if ( lineaPyG.cuentas.value != "" && !lineaPyG.nivelresumen.value ) {
            var importe = 0;
            var cuentas = lineaPyG.cuentas.value.split(",");
            for (var iCuenta = 0 ; iCuenta < cuentas.length ; iCuenta++) {
                var signo = -1;
                var cuenta = cuentas[iCuenta];
                if ( cuenta.indexOf("(") != -1 ) {
                    //signo = -1;
                    cuenta = cuenta.replace("(", "");
                    cuenta = cuenta.replace(")", "");
                }
                var subcuentas = AERPScriptCommon.sqlSelect("SELECT sum(p.debe) as debe, sum(p.haber) as haber " +
                    "FROM co_partidas as p, co_asientos as a, co_subcuentas as s WHERE a.id=p.idasiento AND p.idsubcuenta=s.id AND a.idejercicio=" + idejercicio +
                    " AND a.fecha between " + AERPScriptCommon.sqlDate(fechainicial) + " AND " + AERPScriptCommon.sqlDate(fechafinal) + 
                    " AND s.codsubcuenta like '" + cuenta + "%'");
                if ( subcuentas.length > 0 ) {
                    importe += signo * (subcuentas[0].debe - subcuentas[0].haber);
                    if ( includeCuentaDetail ) {
                        var cuentasDetail = AERPScriptCommon.sqlSelect("SELECT c.codcuenta, c.descripcion, sum(p.debe) as debe, sum(p.haber) as haber " +
                            "FROM co_partidas as p, co_asientos as a, co_subcuentas as s, co_cuentas as c WHERE a.id=p.idasiento AND p.idsubcuenta=s.id AND s.idcuenta = c.id AND a.idejercicio=" + idejercicio +
                            " AND a.fecha between " + AERPScriptCommon.sqlDate(fechainicial) + " AND " + AERPScriptCommon.sqlDate(fechafinal) + 
                            " AND c.codcuenta like '" + cuenta + "%' GROUP BY c.codcuenta, c.descripcion");
                        for ( var iDetail = 0 ; iDetail < cuentasDetail.length ; iDetail++ ) {
                            var lineaCuenta = { 
                                codcuenta: cuentasDetail[iDetail].codcuenta,
                                nombre: cuentasDetail[iDetail].descripcion,
                                importe: signo * (cuentasDetail[iDetail].debe - cuentasDetail[iDetail].haber)
                            }
                            entradaEnPyG.cuentas.push(lineaCuenta);
                        }
                    }                    
                    if ( includeSubcuentaDetail ) {
                        var subcuentasDetail = AERPScriptCommon.sqlSelect("SELECT s.codsubcuenta, s.descripcion, sum(p.debe) as debe, sum(p.haber) as haber " +
                            "FROM co_partidas as p, co_asientos as a, co_subcuentas as s WHERE a.id=p.idasiento AND p.idsubcuenta=s.id AND a.idejercicio=" + idejercicio +
                            " AND a.fecha between " + AERPScriptCommon.sqlDate(fechainicial) + " AND " + AERPScriptCommon.sqlDate(fechafinal) + 
                            " AND s.codsubcuenta like '" + cuenta + "%' GROUP BY s.codsubcuenta, s.descripcion");
                        for ( var iDetail = 0 ; iDetail < subcuentasDetail.length ; iDetail++ ) {
                            var lineaSubcuenta = { 
                                codsubcuenta: subcuentasDetail[iDetail].codsubcuenta,
                                nombre: subcuentasDetail[iDetail].descripcion,
                                importe: signo * (subcuentasDetail[iDetail].debe - subcuentasDetail[iDetail].haber)
                            }
                            entradaEnPyG.subcuentas.push(lineaSubcuenta);
                        }
                    }
                }
                entradaEnPyG.importe = importe;
            }
        }
        pygGenerado.push(entradaEnPyG);
        AERPScriptCommon.setValueProgressDialog(i+1);               
    }
    
    for (var iNivel = 5 ; iNivel > 0 ; iNivel-- ) {
        for (var i = 0 ; i < pygGenerado.length ; i++) {
            if ( pygGenerado[i].nivel.length == iNivel && !pygGenerado[i].hasOwnProperty("importe") ) {
                pygGenerado[i].importe = this.aerpGenerarBalanceSubtotal.call(pygGenerado, pygGenerado[i].nivel);
            }
        }
    }

    // Ahora se calculan los resúmen
    this.aerpCalcularResumenBalance.call(pygGenerado);
    
    for (var i = 0 ; i < pygGenerado.length ; i++) {
        var beanLineaPyG = AERPScriptCommon.createBean("co_pyg_buffer");
        beanLineaPyG.setOverwriteFieldValue("idejercicio", idejercicio);
        beanLineaPyG.idlineapyg.value = pygGenerado[i].id;
        beanLineaPyG.fechainicial.value = fechainicial;
        beanLineaPyG.fechafinal.value = fechafinal;
        beanLineaPyG.importe.value = pygGenerado[i].importe;
        beans.push(beanLineaPyG);
    }
    
    AERPScriptCommon.closeProgressDialog();
    return pygGenerado;
}

})
