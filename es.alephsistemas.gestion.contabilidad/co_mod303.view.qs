function ScriptDlg (ui) {
    this.ui = ui;
    
    this.ui.findChild("pbOk").clicked.connect(this, "imprimir");
    this.ui.findChild("pbGenerar").clicked.connect(this, "generar");
    this.ui.findChild("pbPDF").clicked.connect(this, "generarPDF");
    
    var fechaInicial = new Date();
    fechaInicial.setDate(1);
    fechaInicial.setMonth(0);
    this.ui.findChild("db_fechainicial").value = fechaInicial;
    this.ui.findChild("db_fechafinal").value = new Date();
}


ScriptDlg.prototype.generar = function() {
    var ejercicio = AERPScriptCommon.bean("ejercicios", "id=" + ejercicioActual());
    
    // Mostramos la informaciónew
    var html = "";
    html = "<html><body>";
    html += "<p><strong>MOD 303 - EMPRESA: " + ejercicio.empresas.father.nombre.value + "</strong></p>";
    html += "<p>Datos para el modelo 303 en el período comprendido entre el " + AERPScriptCommon.formatDate(this.ui.findChild("db_fechainicial").value) + 
             " al " + AERPScriptCommon.formatDate(this.ui.findChild("db_fechafinal").value) + "</p>";
    
    html += "<table width='100%' border='0' bgcolor='#CCCCCC' cellpadding='1' cellspacing='1' style='margin-top:5%;margin-bottom:5%;margin-left:10%;margin-right:10%'>";
    html += "<tr><th align='center' style='color:blue;font-weight:bold'>I.V.A. DEVENGADO</th></tr>";
    html += "</table>";
    
    html += this.generarDevengado(ejercicio);

    html += "<table width='100%' border='0' bgcolor='#CCCCCC' cellpadding='1' cellspacing='1' style='margin-top:5%;margin-bottom:5%;margin-left:10%;margin-right:10%'>";
    html += "<tr><th align='center' style='color:blue;font-weight:bold'>I.V.A. DEDUCIBLE</th></tr>";
    html += "</table>";
    
    html += this.generarDeducible(ejercicio);

    html += "<table width='100%' border='0' bgcolor='#CCCCCC' cellpadding='1' cellspacing='1' style='margin-top:5%;margin-bottom:5%;margin-left:10%;margin-right:10%'>";
    html += "<tr><th align='center' style='color:blue;font-weight:bold'>INFORMACIÓN ADICIONAL</th></tr>";
    html += "</table>";
    
    html += this.generarOtraInformacion(ejercicio);

    html = html + "</body></html>";  
    this.ui.findChild("textEdit").html = html;  
}

ScriptDlg.prototype.generarDevengado = function(ejercicio) {
    var totalCuotaDevengada = 0;
    
    var resumen = AERPScriptCommon.sqlSelect("SELECT sum(l.neto) as baseimponible, sum(l.totaliva) as cuota, l.iva as iva FROM lineasivafacturascli as l, facturascli as f, seriesfacturacion as s " +
                               "WHERE f.idserie=s.id AND f.id=l.idfactura AND f.fecha BETWEEN " + AERPScriptCommon.sqlDate(this.ui.findChild("db_fechainicial").value) + 
                               " AND " + AERPScriptCommon.sqlDate(this.ui.findChild("db_fechafinal").value) + " AND l.tipoiva='Sujeta a I.V.A.' " +
                               " AND f.idejercicio=" + ejercicio.id.value + " AND f.idempresa=" + idempresaActual() +
                               " AND f.tipooperacion='Interior' and s.ignoracontabilidad=false GROUP BY l.iva ORDER BY l.iva");
    var html = "<table width='100%' border='0' bgcolor='#CCCCCC' cellpadding='1' cellspacing='1' style='margin-top:5%;margin-bottom:5%;margin-left:10%;margin-right:10%'>";
    html += "<tr><th align='center' colspan='3' bgcolor='#FFFFFF'>RÉGIMEN GENERAL</th></tr>";
    html += "<tr><th align='right' bgcolor='#FFFFFF'>BASE IMPONIBLE</th>";
    html += "<th align='right' bgcolor='#FFFFFF'>TIPO</th>";
    html += "<th align='right' bgcolor='#FFFFFF'>CUOTA</th></tr>";
    
    for (var i = 0 ; i < resumen.length ; i++) {
        html += "<tr>";
        html += "<td bgcolor='#FFFFFF' align='right'>" + AERPScriptCommon.formatNumber(resumen[i].baseimponible, 2) + "&nbsp;€</td>";
        html += "<td bgcolor='#FFFFFF' align='right'>&nbsp;" + AERPScriptCommon.formatNumber(resumen[i].iva, 2) + "&nbsp;%</td>";
        html += "<td bgcolor='#FFFFFF' align='right'>&nbsp;" + AERPScriptCommon.formatNumber(resumen[i].cuota, 2) + "&nbsp;€</td>";
        html += "</tr>";
        totalCuotaDevengada += resumen[i].cuota;
    }
    html += "</table><br/>";

    resumen = AERPScriptCommon.sqlSelect("SELECT sum(l.neto) as baseimponible, sum(l.totaliva) as cuota, l.iva as iva FROM lineasivafacturascli as l, facturascli as f, seriesfacturacion as s " +
                               "WHERE f.idserie=s.id AND f.id=l.idfactura AND f.fecha BETWEEN " + AERPScriptCommon.sqlDate(this.ui.findChild("db_fechainicial").value) + 
                               " AND " + AERPScriptCommon.sqlDate(this.ui.findChild("db_fechafinal").value) + " AND l.tipoiva='Sujeta a I.V.A.' " +
                               " AND f.idejercicio=" + ejercicio.id.value + " AND f.idempresa=" + idempresaActual() +
                               " AND f.tipooperacion='Intracomunitaria' AND s.ignoracontabilidad=false GROUP BY l.iva ORDER BY l.iva");
    html += "<table width='100%' border='0' bgcolor='#CCCCCC' cellpadding='1' cellspacing='1' style='margin-top:5%;margin-bottom:5%;margin-left:10%;margin-right:10%'>";
    html += "<tr><th align='center' colspan='3' bgcolor='#FFFFFF'>ADQUISICIONES INTRACOMUNITARIAS</th></tr>";
    html += "<tr><th align='right' bgcolor='#FFFFFF'>BASE IMPONIBLE</th>";
    html += "<th align='right' bgcolor='#FFFFFF'>TIPO</th>";
    html += "<th align='right' bgcolor='#FFFFFF'>CUOTA</th></tr>";
    
    for (var i = 0 ; i < resumen.length ; i++) {
        html += "<tr>";
        html += "<td bgcolor='#FFFFFF' align='right'>" + AERPScriptCommon.formatNumber(resumen[i].baseimponible, 2) + "&nbsp;€</td>";
        html += "<td bgcolor='#FFFFFF' align='right'>&nbsp;" + AERPScriptCommon.formatNumber(resumen[i].iva, 2) + "&nbsp;%</td>";
        html += "<td bgcolor='#FFFFFF' align='right'>&nbsp;" + AERPScriptCommon.formatNumber(resumen[i].cuota, 2) + "&nbsp;€</td>";
        html += "</tr>";
        totalCuotaDevengada += resumen[i].cuota;
    }
    html += "</table><br/>";

    resumen = AERPScriptCommon.sqlSelect("SELECT sum(l.neto) as baseimponible, l.iva, sum(l.iva * l.neto / 100) as cuota FROM lineasivafacturasprov as l, facturasprov as f, seriesfacturacion as s " +
                               "WHERE f.idserie=s.id AND f.id=l.idfactura AND f.fecha BETWEEN " + AERPScriptCommon.sqlDate(this.ui.findChild("db_fechainicial").value) + 
                               " AND " + AERPScriptCommon.sqlDate(this.ui.findChild("db_fechafinal").value) + " AND l.tipoiva='Inversión de sujeto pasivo' " +
                               " AND f.idejercicio=" + ejercicio.id.value + " AND f.idempresa=" + idempresaActual() +
                               " AND f.tipooperacion='Interior' AND s.ignoracontabilidad=false GROUP BY l.iva ORDER BY l.iva");
    html += "<table width='100%' border='0' bgcolor='#CCCCCC' cellpadding='1' cellspacing='1' style='margin-top:5%;margin-bottom:5%;margin-left:10%;margin-right:10%'>";
    html += "<tr><th align='center' colspan='3' bgcolor='#FFFFFF'>OTRAS OPERACIONES CON INVERSIÓN DEL SUJETO PASIVO</th></tr>";
    html += "<tr><th align='right' bgcolor='#FFFFFF'>BASE IMPONIBLE</th>";
    html += "<th align='right' bgcolor='#FFFFFF'>TIPO</th>";
    html += "<th align='right' bgcolor='#FFFFFF'>CUOTA</th></tr>";
    
    for (var i = 0 ; i < resumen.length ; i++) {
        html += "<tr>";
        html += "<td bgcolor='#FFFFFF' align='right'>" + AERPScriptCommon.formatNumber(resumen[i].baseimponible, 2) + "&nbsp;€</td>";
        html += "<td bgcolor='#FFFFFF' align='right'>" + AERPScriptCommon.formatNumber(resumen[i].iva, 2) + "&nbsp;€</td>";
        html += "<td bgcolor='#FFFFFF' align='right'>&nbsp;" + AERPScriptCommon.formatNumber(resumen[i].cuota, 2) + "&nbsp;€</td>";
        html += "</tr>";
        totalCuotaDevengada += resumen[i].cuota;
    }
    html += "</table><br/>";
    
    var resumen = AERPScriptCommon.sqlSelect("SELECT sum(l.neto) as baseimponible, sum(l.totalrecargo) as cuota, l.recargo as recargo FROM lineasivafacturascli as l, facturascli as f, seriesfacturacion as s " +
                               "WHERE f.idserie=s.id AND f.id=l.idfactura AND f.fecha BETWEEN " + AERPScriptCommon.sqlDate(this.ui.findChild("db_fechainicial").value) + 
                               " AND " + AERPScriptCommon.sqlDate(this.ui.findChild("db_fechafinal").value) + " AND l.tipoiva='Sujeta a I.V.A.' " +
                               " AND f.idejercicio=" + ejercicio.id.value + " AND f.idempresa=" + idempresaActual() +
                               " AND f.tipooperacion='Interior' AND s.ignoracontabilidad=false AND l.recargo > 0 GROUP BY l.recargo ORDER BY l.recargo");
    html += "<table width='100%' border='0' bgcolor='#CCCCCC' cellpadding='1' cellspacing='1' style='margin-top:5%;margin-bottom:5%;margin-left:10%;margin-right:10%'>";
    html += "<tr><th align='center' colspan='3' bgcolor='#FFFFFF'>RECARGO DE EQUIVALENCIA</th></tr>";
    html += "<tr><th align='right' bgcolor='#FFFFFF'>BASE IMPONIBLE</th>";
    html += "<th align='right' bgcolor='#FFFFFF'>TIPO</th>";
    html += "<th align='right' bgcolor='#FFFFFF'>CUOTA</th></tr>";
    
    for (var i = 0 ; i < resumen.length ; i++) {
        html += "<tr>";
        html += "<td bgcolor='#FFFFFF' align='right'>" + AERPScriptCommon.formatNumber(resumen[i].baseimponible, 2) + "&nbsp;€</td>";
        html += "<td bgcolor='#FFFFFF' align='right'>&nbsp;" + AERPScriptCommon.formatNumber(resumen[i].recargo, 2) + "&nbsp;%</td>";
        html += "<td bgcolor='#FFFFFF' align='right'>&nbsp;" + AERPScriptCommon.formatNumber(resumen[i].cuota, 2) + "&nbsp;€</td>";
        html += "</tr>";
        totalCuotaDevengada += resumen[i].cuota;
    }
    html += "</table><br/>";

    html += "<table width='100%' border='0' bgcolor='#CCCCCC' cellpadding='1' cellspacing='1' style='margin-top:5%;margin-bottom:5%;margin-left:10%;margin-right:10%'>";
    html += "<tr><th align='left' bgcolor='#FFFFFF'>TOTAL CUOTA DEVENGADA</th>";
    html += "<th align='right'>" + AERPScriptCommon.formatNumber(totalCuotaDevengada, 2) + "</th></tr>";
    html += "</table><br/>";
    
    return html;     
}

ScriptDlg.prototype.generarDeducible = function(ejercicio) {
    var totalCuota = 0;
    
    var resumen = AERPScriptCommon.sqlSelect("SELECT sum(l.neto) as baseimponible, sum(l.neto * l.iva / 100) as cuota, l.iva as iva FROM lineasivafacturasprov as l, facturasprov as f, seriesfacturacion as s " +
                               "WHERE s.id=f.idserie AND f.id=l.idfactura AND f.fecha BETWEEN " + AERPScriptCommon.sqlDate(this.ui.findChild("db_fechainicial").value) + 
                               " AND " + AERPScriptCommon.sqlDate(this.ui.findChild("db_fechafinal").value) + " AND (l.tipoiva='Sujeta a I.V.A.' or l.tipoiva='Inversión de sujeto pasivo') " +
                               " AND f.idejercicio=" + ejercicio.id.value +  " AND f.idempresa=" + idempresaActual() + " AND l.tipooperacioniva='Deducible' " +
                               " AND f.tipooperacion='Interior' AND s.ignoracontabilidad=false GROUP BY l.iva ORDER BY l.iva");
    var html = "<table width='100%' border='0' bgcolor='#CCCCCC' cellpadding='1' cellspacing='1' style='margin-top:5%;margin-bottom:5%;margin-left:10%;margin-right:10%'>";
    html += "<tr><th align='center' colspan='3' bgcolor='#FFFFFF'>CUOTA SOPORTADA EN OPERACIONES CORRIENTES (INTERIOR)</th></tr>";
    html += "<tr><th align='right' bgcolor='#FFFFFF'>BASE IMPONIBLE</th>";
    html += "<th align='right' bgcolor='#FFFFFF'>TIPO</th>";
    html += "<th align='right' bgcolor='#FFFFFF'>CUOTA</th></tr>";
    
    for (var i = 0 ; i < resumen.length ; i++) {
        html += "<tr>";
        html += "<td bgcolor='#FFFFFF' align='right'>" + AERPScriptCommon.formatNumber(resumen[i].baseimponible, 2) + "&nbsp;€</td>";
        html += "<td bgcolor='#FFFFFF' align='right'>&nbsp;" + AERPScriptCommon.formatNumber(resumen[i].iva, 2) + "&nbsp;%</td>";
        html += "<td bgcolor='#FFFFFF' align='right'>&nbsp;" + AERPScriptCommon.formatNumber(resumen[i].cuota, 2) + "&nbsp;€</td>";
        html += "</tr>";
        totalCuota += resumen[i].cuota;
    }
    html += "</table><br/>";

    html += "<table width='100%' border='0' bgcolor='#CCCCCC' cellpadding='1' cellspacing='1' style='margin-top:5%;margin-bottom:5%;margin-left:10%;margin-right:10%'>";
    html += "<tr><th align='left' bgcolor='#FFFFFF'>TOTAL CUOTA DEDUCIR</th>";
    html += "<th align='right'>" + AERPScriptCommon.formatNumber(totalCuota, 2) + "</th></tr>";
    html += "</table><br/>";
    
    return html;     
}

ScriptDlg.prototype.generarOtraInformacion = function(ejercicio) {
    var totalCuota = 0;
    
    var resumen = AERPScriptCommon.sqlSelect("SELECT sum(l.neto) as baseimponible FROM lineasivafacturascli as l, facturascli as f, seriesfacturacion as s " +
                               "WHERE s.id=f.idserie AND f.id=l.idfactura AND f.fecha BETWEEN " + AERPScriptCommon.sqlDate(this.ui.findChild("db_fechainicial").value) + 
                               " AND " + AERPScriptCommon.sqlDate(this.ui.findChild("db_fechafinal").value) + " AND l.tipoiva='Exenta de I.V.A.' " +
                               " AND s.ignoracontabilidad=false AND f.idejercicio=" + ejercicio.id.value + " AND f.idempresa=" + idempresaActual());
    var html = "<table width='100%' border='0' bgcolor='#CCCCCC' cellpadding='1' cellspacing='1' style='margin-top:5%;margin-bottom:5%;margin-left:10%;margin-right:10%'>";
    html += "<tr><th align='center' bgcolor='#FFFFFF'></th>";
    html += "<th align='right' bgcolor='#FFFFFF'>BASE IMPONIBLE</th></tr>";
    
    html += "<tr>";
    html += "<td bgcolor='#FFFFFF' align='left'>OPERACIONES EXENTAS DE IVA</td>";
    html += "<td bgcolor='#FFFFFF' align='right'>&nbsp;" + AERPScriptCommon.formatNumber(resumen[0].baseimponible, 2) + "&nbsp;€</td>";
    html += "</tr>";

    resumen = AERPScriptCommon.sqlSelect("SELECT sum(l.neto) as baseimponible FROM lineasivafacturascli as l, facturascli as f, seriesfacturacion as s " +
                               "WHERE s.id=f.idserie AND f.id=l.idfactura AND f.fecha BETWEEN " + AERPScriptCommon.sqlDate(this.ui.findChild("db_fechainicial").value) + 
                               " AND " + AERPScriptCommon.sqlDate(this.ui.findChild("db_fechafinal").value) + " AND l.tipoiva='Inversión de sujeto pasivo' " +
                               " AND s.ignoracontabilidad=false AND f.idejercicio=" + ejercicio.id.value +  " AND f.idempresa=" + idempresaActual());
    html += "<tr>";
    html += "<td bgcolor='#FFFFFF' align='left'>INVERSIÓN DE SUJETO PASIVO</td>";
    html += "<td bgcolor='#FFFFFF' align='right'>&nbsp;" + AERPScriptCommon.formatNumber(resumen[0].baseimponible, 2) + "&nbsp;€</td>";
    html += "</tr>";

    resumen = AERPScriptCommon.sqlSelect("SELECT sum(l.neto) as baseimponible FROM lineasivafacturascli as l, facturascli as f, seriesfacturacion as s " +
                               "WHERE s.id=f.idserie AND f.id=l.idfactura AND f.fecha BETWEEN " + AERPScriptCommon.sqlDate(this.ui.findChild("db_fechainicial").value) + 
                               " AND " + AERPScriptCommon.sqlDate(this.ui.findChild("db_fechafinal").value) + " AND l.tipoiva='No sujeta a I.V.A.' " +
                               " AND s.ignoracontabilidad=false AND f.idejercicio=" + ejercicio.id.value +  " AND f.idempresa=" + idempresaActual());
    html += "<tr>";
    html += "<td bgcolor='#FFFFFF' align='left'>OPERACIONES NO SUJETAS A IVA</td>";
    html += "<td bgcolor='#FFFFFF' align='right'>&nbsp;" + AERPScriptCommon.formatNumber(resumen[0].baseimponible, 2) + "&nbsp;€</td>";
    html += "</tr>";
    
    html += "</table>";
    return html;     
}

/*
ScriptDlg.prototype.generarOtraInformacionRecibidas = function(ejercicio) {
    var totalCuota = 0;
    
    var resumen = AERPScriptCommon.sqlSelect("SELECT sum(l.neto) as baseimponible FROM lineasivafacturasprov as l, facturasprov as f " +
                               "WHERE f.id=l.idfactura AND f.fecha BETWEEN " + AERPScriptCommon.sqlDate(this.ui.findChild("db_fechainicial").value) + 
                               " AND " + AERPScriptCommon.sqlDate(this.ui.findChild("db_fechafinal").value) + " AND l.tipoiva='Exenta de I.V.A.' " +
                               " AND f.idejercicio=" + ejercicio.id.value);
    var html = "<table width='100%' border='0' bgcolor='#CCCCCC' cellpadding='1' cellspacing='1' style='margin-top:5%;margin-bottom:5%;margin-left:10%;margin-right:10%'>";
    html += "<tr><th align='center' bgcolor='#FFFFFF'></th>";
    html += "<th align='right' bgcolor='#FFFFFF'>BASE IMPONIBLE</th></tr>";
    
    html += "<tr>";
    html += "<td bgcolor='#FFFFFF' align='left'>OPERACIONES EXENTAS DE IVA</td>";
    html += "<td bgcolor='#FFFFFF' align='right'>&nbsp;" + AERPScriptCommon.formatNumber(resumen[0].baseimponible, 2) + "&nbsp;€</td>";
    html += "</tr>";

    resumen = AERPScriptCommon.sqlSelect("SELECT sum(l.neto) as baseimponible FROM lineasivafacturasprov as l, facturasprov as f " +
                               "WHERE f.id=l.idfactura AND f.fecha BETWEEN " + AERPScriptCommon.sqlDate(this.ui.findChild("db_fechainicial").value) + 
                               " AND " + AERPScriptCommon.sqlDate(this.ui.findChild("db_fechafinal").value) + " AND l.tipoiva='Inversión de sujeto pasivo' " +
                               " AND f.idejercicio=" + ejercicio.id.value);
    html += "<tr>";
    html += "<td bgcolor='#FFFFFF' align='left'>INVERSIÓN DE SUJETO PASIVO</td>";
    html += "<td bgcolor='#FFFFFF' align='right'>&nbsp;" + AERPScriptCommon.formatNumber(resumen[0].baseimponible, 2) + "&nbsp;€</td>";
    html += "</tr>";

    resumen = AERPScriptCommon.sqlSelect("SELECT sum(l.neto) as baseimponible FROM lineasivafacturasprov as l, facturasprov as f " +
                               "WHERE f.id=l.idfactura AND f.fecha BETWEEN " + AERPScriptCommon.sqlDate(this.ui.findChild("db_fechainicial").value) + 
                               " AND " + AERPScriptCommon.sqlDate(this.ui.findChild("db_fechafinal").value) + " AND l.tipoiva='No sujeta a I.V.A.' " +
                               " AND f.idejercicio=" + ejercicio.id.value);
    html += "<tr>";
    html += "<td bgcolor='#FFFFFF' align='left'>OPERACIONES NO SUJETAS A IVA</td>";
    html += "<td bgcolor='#FFFFFF' align='right'>&nbsp;" + AERPScriptCommon.formatNumber(resumen[0].baseimponible, 2) + "&nbsp;€</td>";
    html += "</tr>";
    
    html += "</table>";
    return html;     
}
*/

ScriptDlg.prototype.imprimir = function() {    
    AERPLoadExtension("alepherp.openrpt");
    var bean = AERPScriptCommon.createBean("co_buffer_impresion");
    bean.buffer.value = this.ui.findChild("textEdit").html;
    bean.save();
    var reportName = "co_mod303.xml";
    var openRPT = createOpenRPT();
    openRPT.reportName = reportName;
    openRPT.setParamValue("P_ID", bean.id.value);
    openRPT.widgetParent = thisForm;
    openRPT.filePreview();
}

ScriptDlg.prototype.generarPDF = function() {    
    AERPLoadExtension("alepherp.openrpt");
    var bean = AERPScriptCommon.createBean("co_buffer_impresion");
    bean.buffer.value = this.ui.findChild("textEdit").html;
    bean.save();
    var reportName = "co_mod303.xml";
    var openRPT = createOpenRPT();
    openRPT.reportName = reportName;
    openRPT.setParamValue("P_ID", bean.id.value);
    openRPT.widgetParent = thisForm;
    openRPT.filePrintToPDF();
}
