function DBFormDlg (ui) {
    AERPLoadExtension("qt.core");
    AERPLoadExtension("qt.gui");
    
    this.ui = ui;
    if ( AERPScriptCommon.hasRole("contabilidad") ) {
        thisForm.createPushButton(13, 
                                                "Exportar asientos contables", 
                                                "Exportar asientos contables a Contaplus", 
                                                "", 
                                                "exportarAsientos");
    }
}

if (typeof String.prototype.startsWith != 'function') {
    String.prototype.startsWith = function (str){
        return this.indexOf(str) == 0;
    };
}

function containsSubcuenta(subcuentas, subcuenta) {
    for(var j = 0 ; j < subcuentas.length ; j++) {
        if ( subcuentas[j].id.value == subcuenta.id.value ) {
            return true;
        }
    }
    return false;
}

DBFormDlg.prototype.exportarAsientos = function() {
    var empActual = empresaActual();
    var subcuentas = new Array();
    AERPMessageBox.information("Este script exportará en formato XBASE de Contaplus los asientos contables del libro diario que no hayan sido exportados anteriormente, de la empresa: " + empActual.nombre.value);

    var fecha1 = AERPScriptCommon.getDate("Introduzca la fecha de inicio desde la escoger los asientos a exportar.");
    if ( fecha1 == undefined ) {
        return;
    }
    var fecha2 = AERPScriptCommon.getDate("Introduzca la fecha de finalización desde la escoger los asientos a exportar.");
    if ( fecha2 == undefined ) {
        return;
    }

    var directorio = AERPScriptCommon.getExistingDirectory("Seleccione el directorio donde se ubicarán los ficheros de exportación");
    if ( directorio == "" ) {
        return;
    }

    var archivo = AERPScriptCommon.createSpreadSheet(directorio + "/XDiario.dbf", "dbf");
    var sheet = archivo.createSheet("asientos");

    sheet.setColumn(0, "ASIEN", AERPSpreadSheet.Int, 6, 0);
    sheet.setColumn(1, "FECHA", AERPSpreadSheet.Date, 8, 0);
    sheet.setColumn(2, "SUBCTA", AERPSpreadSheet.String, 12, 0);
    sheet.setColumn(3, "CONTRA", AERPSpreadSheet.String, 12, 0);
    sheet.setColumn(4, "PTADEBE", AERPSpreadSheet.Double, 16, 2);
    sheet.setColumn(5, "CONCEPTO", AERPSpreadSheet.String, 25, 0);
    sheet.setColumn(6, "PTAHABER", AERPSpreadSheet.Double, 16, 2);
    sheet.setColumn(7, "FACTURA", AERPSpreadSheet.Int, 8, 0);
    sheet.setColumn(8, "BASEIMP", AERPSpreadSheet.Double, 16, 2);
    sheet.setColumn(9, "IVA", AERPSpreadSheet.Double, 5, 2);
    sheet.setColumn(10, "RECEQUIV", AERPSpreadSheet.Double, 5, 2);
    sheet.setColumn(11, "DOCUMENTO", AERPSpreadSheet.String, 10, 0);
    sheet.setColumn(12, "EURODEBE", AERPSpreadSheet.Double, 16, 2);
    sheet.setColumn(13, "EUROHABER", AERPSpreadSheet.Double, 16, 2);
    sheet.setColumn(14, "BASEEURO", AERPSpreadSheet.Double, 16, 2);

    var beans = AERPScriptCommon.beans("co_asientos", "idempresa = " + empActual.id.value + " and fecha >= " + AERPScriptCommon.sqlDate(fecha1) +
                            " and fecha <= " + AERPScriptCommon.sqlDate(fecha2), "numero asc");
    AERPScriptCommon.showProgressDialog("Generando fichero con los datos del libro diario...", beans.length + 1);

    var row = 0;
    for (var i = 0 ; i < beans.length ; i++ ) {
        var asiento = beans[i];
        for ( var line = 0 ; line < asiento.co_partidas.items.length ; line++ ) {
            var partida = asiento.co_partidas.items[line]
            var subcuentaLinea = partida.co_subcuentas.father.codsubcuenta.value;
            if ( !containsSubcuenta(subcuentas, partida.co_subcuentas.father) ) {
                subcuentas[subcuentas.length] = partida.co_subcuentas.father;
            }
            sheet.createCell(row, 0, asiento.numero.value); 
            sheet.createCell(row ,1, asiento.fecha.value);
            sheet.createCell(row, 2, subcuentaLinea);
            sheet.createCell(row, 3, "");
            sheet.createCell(row, 4, partida.debe.value / 166.386);
            sheet.createCell(row, 5, partida.concepto.value);
            sheet.createCell(row, 6, partida.haber.value / 166.386);
            sheet.createCell(row, 7, "");
            sheet.createCell(row, 8, 0);
            sheet.createCell(row, 9, 0);
            sheet.createCell(row, 10, 0);
            sheet.createCell(row, 11, "");
            sheet.createCell(row, 12, partida.debe.value);
            sheet.createCell(row, 13, partida.haber.value);
            sheet.createCell(row, 14, 0);
            row++;
        }
        AERPScriptCommon.setValueProgressDialog(i);       
        AERPDebug("Se ha exportado el asiento " + asiento.numero.value);
    }
    AERPScriptCommon.setLabelProgressDialog("Creando archivo DBASE para Contaplus con el libro diario...");
    if ( !archivo.save() ) {
        AERPMessageBox.warning("Ha ocurrido un error guardando el archivo DBASE para Contaplus. El error es: " + archivo.lastMessage);
        return;
    }

    AERPScriptCommon.closeProgressDialog();

    AERPScriptCommon.showProgressDialog("Generando fichero con los datos subcuentas...", beans.length + 1);

    var archivoSubcuentas = AERPScriptCommon.createSpreadSheet("/home/david/XSubCta.dbf", "dbf");
    var sheetSubcuentas = archivoSubcuentas.createSheet("asientos");

    sheetSubcuentas.setColumn(0, "COD", AERPSpreadSheet.String, 12, 0);
    sheetSubcuentas.setColumn(1, "TITULO", AERPSpreadSheet.String, 40, 0);
    sheetSubcuentas.setColumn(2, "NIF", AERPSpreadSheet.String, 15, 0);
    sheetSubcuentas.setColumn(3, "DOMICILIO", AERPSpreadSheet.String, 15, 0);
    sheetSubcuentas.setColumn(4, "POBLACION", AERPSpreadSheet.String, 25, 0);
    sheetSubcuentas.setColumn(5, "PROVINCIA", AERPSpreadSheet.String, 20, 0);
    sheetSubcuentas.setColumn(6, "CODPOSTAL", AERPSpreadSheet.String, 5, 0);
    sheetSubcuentas.setColumn(7, "DIVISA", AERPSpreadSheet.Bool, 1, 0);
    sheetSubcuentas.setColumn(8, "CODDIVISA", AERPSpreadSheet.String, 5, 0);
    sheetSubcuentas.setColumn(9, "DOCUMENTO", AERPSpreadSheet.Bool, 1, 0);
    sheetSubcuentas.setColumn(10, "AJUSTAME", AERPSpreadSheet.Bool, 1, 0);
    sheetSubcuentas.setColumn(11, "TIPOIVA", AERPSpreadSheet.String, 1, 0);
    sheetSubcuentas.setColumn(12, "PROYE", AERPSpreadSheet.String, 9, 0);
    sheetSubcuentas.setColumn(13, "SUBEQUIV", AERPSpreadSheet.String, 12, 0);
    sheetSubcuentas.setColumn(14, "SUBCIERRE", AERPSpreadSheet.String, 12, 0);
    sheetSubcuentas.setColumn(15, "LINTERRUMP", AERPSpreadSheet.Bool, 1, 0);
    sheetSubcuentas.setColumn(16, "SEGMENTO", AERPSpreadSheet.String, 12, 0);

    for (var i = 0 ; i < subcuentas.length ; i++) {
        sheetSubcuentas.createCell(i, 0, subcuentas[i].codsubcuenta.value); 
        sheetSubcuentas.createCell(i, 1, subcuentas[i].descripcion.value); 
        sheetSubcuentas.createCell(i, 7, false); 
        sheetSubcuentas.createCell(i, 9, false); 
        sheetSubcuentas.createCell(i, 10, false); 
        sheetSubcuentas.createCell(i, 15, false); 
        AERPScriptCommon.setValueProgressDialog(i);          
    }
    AERPScriptCommon.setLabelProgressDialog("Creando archivo DBASE para Contaplus con las subcuentas contables...");
    if ( !archivoSubcuentas.save() ) {
        AERPMessageBox.warning("Ha ocurrido un error guardando el archivo DBASE para Contaplus. El error es: " + archivoSubcuentas.lastMessage);
        return;
    }
    AERPScriptCommon.closeProgressDialog();

    AERPMessageBox.information("Se ha realizado la exportación de forma correcta.");
}
