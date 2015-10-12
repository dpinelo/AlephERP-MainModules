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
    html += "<p><strong>MOD 111 - EMPRESA: " + ejercicio.empresas.father.nombre.value + "</strong></p>";
    html += "<p>Datos para el modelo 111 en el período comprendido entre el " + AERPScriptCommon.formatDate(this.ui.findChild("db_fechainicial").value) + 
             " al " + AERPScriptCommon.formatDate(this.ui.findChild("db_fechafinal").value) + "</p>";
    
    html += "<table width='100%' border='0' bgcolor='#CCCCCC' cellpadding='1' cellspacing='1' style='margin-top:5%;margin-bottom:5%;margin-left:10%;margin-right:10%'>";
    html += "<tr><th align='center' style='color:blue;font-weight:bold'>DATOS PARA LIQUIDACIÓN II. RENDIMIENTOS DE ACTIVIDADES ECONÓMICAS</th></tr>";
    html += "</table>";
    
    html += this.generarDatos(ejercicio);

    html = html + "</body></html>";  
    this.ui.findChild("textEdit").html = html;  
}

ScriptDlg.prototype.generarDatos = function(ejercicio) {
    var resumenPerceptores = AERPScriptCommon.sqlSelect("SELECT count(f.idtercero) as perceptores FROM lineasserviciosfacturasprov as l, facturasprov as f " +
                               "WHERE f.id=l.idfactura AND f.fecha BETWEEN " + AERPScriptCommon.sqlDate(this.ui.findChild("db_fechainicial").value) + 
                               " AND " + AERPScriptCommon.sqlDate(this.ui.findChild("db_fechafinal").value) + 
                               " AND f.idejercicio=" + ejercicio.id.value +
                               " AND f.tipooperacion='Interior' AND l.irpf>0");
    var perceptores = resumenPerceptores[0].perceptores;
    
    var resumen = AERPScriptCommon.sqlSelect("SELECT sum(l.importetotal) as baseimponible, sum(l.irpf * l.importetotal / 100) as cuota FROM lineasserviciosfacturasprov as l, facturasprov as f " +
                               "WHERE f.id=l.idfactura AND f.fecha BETWEEN " + AERPScriptCommon.sqlDate(this.ui.findChild("db_fechainicial").value) + 
                               " AND " + AERPScriptCommon.sqlDate(this.ui.findChild("db_fechafinal").value) + 
                               " AND f.idejercicio=" + ejercicio.id.value +
                               " AND f.tipooperacion='Interior' AND l.irpf>0");
    var html = "<table width='100%' border='0' bgcolor='#CCCCCC' cellpadding='1' cellspacing='1' style='margin-top:5%;margin-bottom:5%;margin-left:10%;margin-right:10%'>";
    html += "<tr><th align='center' colspan='3' bgcolor='#FFFFFF'>RENDIMIENTOS DINERARIOS</th></tr>";
    html += "<tr><th align='right' bgcolor='#FFFFFF'>Nº DE PERCEPTORES</th>";
    html += "<th align='right' bgcolor='#FFFFFF'>IMPORTE DE LAS PERCEPCIONES</th>";
    html += "<th align='right' bgcolor='#FFFFFF'>IMPORTE DE LAS RETENCIONES</th></tr>";
    
    html += "<tr>";
    html += "<td bgcolor='#FFFFFF' align='right'>" + AERPScriptCommon.formatNumber(perceptores, 2) + "&nbsp;</td>";
    html += "<td bgcolor='#FFFFFF' align='right'>&nbsp;" + AERPScriptCommon.formatNumber(resumen[0].baseimponible, 2) + "&nbsp;€</td>";
    html += "<td bgcolor='#FFFFFF' align='right'>&nbsp;" + AERPScriptCommon.formatNumber(resumen[0].cuota, 2) + "&nbsp;€</td>";
    html += "</tr>";
    html += "</table><br/>";

    return html;     
}

ScriptDlg.prototype.imprimir = function() {    
    AERPLoadExtension("alepherp.openrpt");
    var bean = AERPScriptCommon.createBean("co_buffer_impresion");
    bean.buffer.value = this.ui.findChild("textEdit").html;
    bean.save();
    var reportName = "co_mod111.xml";
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
    var reportName = "co_mod111.xml";
    var openRPT = createOpenRPT();
    openRPT.reportName = reportName;
    openRPT.setParamValue("P_ID", bean.id.value);
    openRPT.widgetParent = thisForm;
    openRPT.filePrintToPDF();
}

