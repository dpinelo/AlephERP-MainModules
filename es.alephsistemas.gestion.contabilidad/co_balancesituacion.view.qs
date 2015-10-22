function ScriptDlg (ui) {
    this.ui = ui;
    
    this.ui.findChild("pbOk").clicked.connect(this, "okClicked");
    this.ui.findChild("pbPDF").clicked.connect(this, "generarPDF");
    this.ui.findChild("pbGenerar").clicked.connect(this, "generarBalance");
    
    var fechaInicial = new Date();
    fechaInicial.setDate(1);
    fechaInicial.setMonth(0);
    this.ui.findChild("db_fechainicial").value = fechaInicial;
    this.ui.findChild("db_fechafinal").value = new Date();
    
    this.ui.findChild("pbPrintPreview").visible = AERPScriptCommon.hasOwnProperty("printPreviewHtml");
    this.ui.findChild("pbPrint").visible = AERPScriptCommon.hasOwnProperty("printPreviewHtml");
    this.ui.findChild("pbPrint").clicked.connect(this, "imprimir");    
    this.ui.findChild("pbPrintPreview").clicked.connect(this, "previsualizar");        
}


ScriptDlg.prototype.generarBalance = function() {
    var ejercicio = AERPScriptCommon.bean("ejercicios", "id=" + ejercicioActual());
    var nivel = this.ui.findChild("cbNivel").currentIndex + 2;
    
    var balance = ejercicio.aerpGenerarBalance.call(this.ui.findChild("db_fechainicial").value, 
                                                              this.ui.findChild("db_fechafinal").value,
                                                              nivel == 4, nivel == 5);
    var beanLineasBalance = balance.balanceGenerado;
    
    // Mostramos la informaciónew
    var html = "";
    html = "<html><body>";
    html += "<p><strong>BALANCE DE SITUACIÓN - EMPRESA: " + ejercicio.empresas.father.nombre.value + "</strong></p>";
    /*
    html += "<p>Balance de situación en el período comprendido entre el " + AERPScriptCommon.formatDate(this.ui.findChild("db_fechainicial").value) + 
             " al " + AERPScriptCommon.formatDate(this.ui.findChild("db_fechafinal").value) + "</p>";
    */
    html += "<p>Balance de situación en el período comprendido entre el " + this.ui.findChild("db_fechainicial").value + 
             " al " + this.ui.findChild("db_fechafinal").value + "</p>";
    
    html += "<table width='100%' border='0' bgcolor='#CCCCCC' cellpadding='1' cellspacing='1' style='margin-top:5%;margin-bottom:5%;margin-left:10%;margin-right:10%'>";
    html += "<tr><th align='center' colspan='2'>ACTIVO</th></tr>";
    
    for (var i = 0 ; i < beanLineasBalance.length ; i++) {
        if ( beanLineasBalance[i].naturaleza == "ACTIVO" ) {
            if ( beanLineasBalance[i].nivelresumen || beanLineasBalance[i].nivel.length == 1 ) {
                html += "<tr>";
                html += "<td width='80%' bgcolor='#FFFFFF' align='left' style='color:blue;font-weight:bold'>" + beanLineasBalance[i].nombre + "</td>";
                html += "<td width='20%' bgcolor='#FFFFFF' align='right' style='color:blue;font-weight:bold'>&nbsp;" + AERPScriptCommon.formatNumber(beanLineasBalance[i].importe, 2) + "&nbsp;€</td>";
                html += "</tr>";
            }
            if ( !beanLineasBalance[i].nivelresumen && beanLineasBalance[i].nivel.length == 2 && beanLineasBalance[i].nivel.length <= nivel ) {
                html += "<tr>";
                html += "<td width='80%' bgcolor='#FFFFFF' align='left'>&nbsp;&nbsp;&nbsp;&nbsp;<strong>" + beanLineasBalance[i].nombre + "</strong></td>";
                html += "<td width='20%' bgcolor='#FFFFFF' align='right'>&nbsp;<strong>" + AERPScriptCommon.formatNumber(beanLineasBalance[i].importe, 2) + "</strong>&nbsp;€</td>";
                html += "</tr>";
            }
            if ( !beanLineasBalance[i].nivelresumen && beanLineasBalance[i].nivel.length == 3 && beanLineasBalance[i].nivel.length <= nivel ) {
                html += "<tr>";
                html += "<td width='80%' bgcolor='#FFFFFF' align='left'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + beanLineasBalance[i].nombre + "</td>";
                html += "<td width='20%' bgcolor='#FFFFFF' align='right'>&nbsp;" + AERPScriptCommon.formatNumber(beanLineasBalance[i].importe, 2) + "&nbsp;€</td>";
                html += "</tr>";
            }
            if ( !beanLineasBalance[i].nivelresumen && nivel >= 4 ) {
                for (var iCuenta = 0 ; iCuenta < beanLineasBalance[i].cuentas.length ; iCuenta++) {
                    var cuenta = beanLineasBalance[i].cuentas[iCuenta];
                    html += "<tr>";
                    html += "<td width='80%' bgcolor='#FFFFFF' align='left'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + cuenta.codcuenta + ". " + cuenta.nombre + "</td>";
                    html += "<td width='20%' bgcolor='#FFFFFF' align='right'>&nbsp;" + AERPScriptCommon.formatNumber(cuenta.importe, 2) + "&nbsp;€</td>";
                    html += "</tr>";
                }
            }            
            if ( !beanLineasBalance[i].nivelresumen && nivel == 5 ) {
                for (var iSubcuenta = 0 ; iSubcuenta < beanLineasBalance[i].subcuentas.length ; iSubcuenta++) {
                    var subcuenta = beanLineasBalance[i].subcuentas[iSubcuenta];
                    html += "<tr>";
                    html += "<td width='80%' bgcolor='#FFFFFF' align='left'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + subcuenta.codsubcuenta + ". " + subcuenta.nombre + "</td>";
                    html += "<td width='20%' bgcolor='#FFFFFF' align='right'>&nbsp;" + AERPScriptCommon.formatNumber(subcuenta.importe, 2) + "&nbsp;€</td>";
                    html += "</tr>";
                }
            }
        }
    }
    html += "</table>";
    
    html = html + "</body></html>";  
    this.ui.findChild("textEditActivo").html = html;
    
    // Mostramos la informaciónew
    html = "";
    html = "<html><body>";
    html += "<p><strong>BALANCE DE SITUACIÓN - EMPRESA: " + ejercicio.empresas.father.nombre.value + "</strong></p>";
    /*
    html += "<p>Balance de situación en el período comprendido entre el " + AERPScriptCommon.formatDate(this.ui.findChild("db_fechainicial").value) + 
             " al " + AERPScriptCommon.formatDate(this.ui.findChild("db_fechafinal").value) + "</p>";
    */
    html += "<p>Balance de situación en el período comprendido entre el " + this.ui.findChild("db_fechainicial").value + 
             " al " + this.ui.findChild("db_fechafinal").value + "</p>";
    
    html += "<table width='100%' border='0' bgcolor='#CCCCCC' cellpadding='1' cellspacing='1' style='margin-top:5%;margin-bottom:5%;margin-left:10%;margin-right:10%'>";
    html += "<tr><th align='center' colspan='2'>PASIVO</th></tr>";
    
    for (var i = 0 ; i < beanLineasBalance.length ; i++) {
        if ( beanLineasBalance[i].naturaleza == "PASIVO" ) {
            if ( beanLineasBalance[i].nivelresumen || beanLineasBalance[i].nivel.length == 1 ) {
                html += "<tr>";
                html += "<td width='80%' bgcolor='#FFFFFF' align='left' style='color:blue;font-weight:bold'>" + beanLineasBalance[i].nombre + "</td>";
                html += "<td width='20%' bgcolor='#FFFFFF' align='right' style='color:blue;font-weight:bold'>&nbsp;" + AERPScriptCommon.formatNumber(beanLineasBalance[i].importe, 2) + "&nbsp;€</td>";
                html += "</tr>";
            }
            if ( !beanLineasBalance[i].nivelresumen && beanLineasBalance[i].nivel.length == 2 && beanLineasBalance[i].nivel.length <= nivel ) {
                html += "<tr>";
                html += "<td width='80%' bgcolor='#FFFFFF' align='left'>&nbsp;&nbsp;&nbsp;&nbsp;<strong>" + beanLineasBalance[i].nombre + "</strong></td>";
                html += "<td width='20%' bgcolor='#FFFFFF' align='right'>&nbsp;<strong>" + AERPScriptCommon.formatNumber(beanLineasBalance[i].importe, 2) + "</strong>&nbsp;€</td>";
                html += "</tr>";
            }
            if ( !beanLineasBalance[i].nivelresumen && beanLineasBalance[i].nivel.length == 3 && beanLineasBalance[i].nivel.length <= nivel ) {
                html += "<tr>";
                html += "<td width='80%' bgcolor='#FFFFFF' align='left'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + beanLineasBalance[i].nombre + "</td>";
                html += "<td width='20%' bgcolor='#FFFFFF' align='right'>&nbsp;" + AERPScriptCommon.formatNumber(beanLineasBalance[i].importe, 2) + "&nbsp;€</td>";
                html += "</tr>";
            }
            if ( !beanLineasBalance[i].nivelresumen && nivel >= 4 ) {
                for (var iCuenta = 0 ; iCuenta < beanLineasBalance[i].cuentas.length ; iCuenta++) {
                    var cuenta = beanLineasBalance[i].cuentas[iCuenta];
                    html += "<tr>";
                    html += "<td width='80%' bgcolor='#FFFFFF' align='left'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + cuenta.codcuenta + ". " + cuenta.nombre + "</td>";
                    html += "<td width='20%' bgcolor='#FFFFFF' align='right'>&nbsp;" + AERPScriptCommon.formatNumber(cuenta.importe, 2) + "&nbsp;€</td>";
                    html += "</tr>";
                }
            }                        
            if ( !beanLineasBalance[i].nivelresumen && nivel == 5 ) {
                for (var iSubcuenta = 0 ; iSubcuenta < beanLineasBalance[i].subcuentas.length ; iSubcuenta++) {
                    var subcuenta = beanLineasBalance[i].subcuentas[iSubcuenta];
                    html += "<tr>";
                    html += "<td width='80%' bgcolor='#FFFFFF' align='left'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + subcuenta.codsubcuenta + ". " + subcuenta.nombre + "</td>";
                    html += "<td width='20%' bgcolor='#FFFFFF' align='right'>&nbsp;" + AERPScriptCommon.formatNumber(subcuenta.importe, 2) + "&nbsp;€</td>";
                    html += "</tr>";
                }
            }
        }
    }
    html += "</table>";
    
    html = html + "</body></html>";  
    this.ui.findChild("textEditPasivo").html = html;      
    
        // Mostramos la informaciónew
    var beanLineasPyG = balance.pyg;
    html = "";
    html = "<html><body>";
    html += "<p><strong>CUENTA DE PÉRDIDAS Y GANANCIAS - EMPRESA: " + ejercicio.empresas.father.nombre.value + "</strong></p>";
    /*
    html += "<p>Cuenta de pérdidas y ganancias en el período comprendido entre el " + AERPScriptCommon.formatDate(this.ui.findChild("db_fechainicial").value) + 
             " al " + AERPScriptCommon.formatDate(this.ui.findChild("db_fechafinal").value) + "</p>";
    */
    html += "<p>Cuenta de pérdidas y ganancias en el período comprendido entre el " + this.ui.findChild("db_fechainicial").value + 
             " al " + this.ui.findChild("db_fechafinal").value + "</p>";
    
    html += "<table width='100%' border='0' bgcolor='#CCCCCC' cellpadding='1' cellspacing='1' style='margin-top:5%;margin-bottom:5%;margin-left:10%;margin-right:10%'>";
    html += "<tr><th align='center' colspan='2'>CUENTA DE PÉRDIDAS Y GANANCIAS</th></tr>";
    
    for (var i = 0 ; i < beanLineasPyG.length ; i++) {
        if ( beanLineasPyG[i].nivelresumen ) {
            html += "<tr>";
            html += "<td width='80%' bgcolor='#FFFFFF' align='left' style='color:blue;font-weight:bold'>" + beanLineasPyG[i].nombre + "</td>";
            html += "<td width='20%' bgcolor='#FFFFFF' align='right' style='color:blue;font-weight:bold'>&nbsp;" + AERPScriptCommon.formatNumber(beanLineasPyG[i].importe, 2) + "&nbsp;€</td>";
            html += "</tr>";
        }
        if ( !beanLineasPyG[i].nivelresumen && beanLineasPyG[i].nivel.length == 2 && beanLineasPyG[i].nivel.length <= nivel ) {
            html += "<tr>";
            html += "<td width='80%' bgcolor='#FFFFFF' align='left'>&nbsp;&nbsp;&nbsp;&nbsp;<strong>" + beanLineasPyG[i].nombre + "</strong></td>";
            html += "<td width='20%' bgcolor='#FFFFFF' align='right'>&nbsp;<strong>" + AERPScriptCommon.formatNumber(beanLineasPyG[i].importe, 2) + "</strong>&nbsp;€</td>";
            html += "</tr>";
        }
        if ( !beanLineasPyG[i].nivelresumen && beanLineasPyG[i].nivel.length == 3 && beanLineasPyG[i].nivel.length <= nivel ) {
            html += "<tr>";
            html += "<td width='80%' bgcolor='#FFFFFF' align='left'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + beanLineasPyG[i].nombre + "</td>";
            html += "<td width='20%' bgcolor='#FFFFFF' align='right'>&nbsp;" + AERPScriptCommon.formatNumber(beanLineasPyG[i].importe, 2) + "&nbsp;€</td>";
            html += "</tr>";
        }
        if ( !beanLineasPyG[i].nivelresumen && nivel == 4 ) {
            for (var iCuenta = 0 ; iCuenta < beanLineasPyG[i].cuentas.length ; iCuenta++) {
                var cuenta = beanLineasPyG[i].cuentas[iCuenta];
                html += "<tr>";
                html += "<td width='80%' bgcolor='#FFFFFF' align='left'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + cuenta.codcuenta + ". " + cuenta.nombre + "</td>";
                html += "<td width='20%' bgcolor='#FFFFFF' align='right'>&nbsp;" + AERPScriptCommon.formatNumber(cuenta.importe, 2) + "&nbsp;€</td>";
                html += "</tr>";
            }
        }        
        if ( !beanLineasPyG[i].nivelresumen && nivel == 5 ) {
            for (var iSubcuenta = 0 ; iSubcuenta < beanLineasPyG[i].subcuentas.length ; iSubcuenta++) {
                var subcuenta = beanLineasPyG[i].subcuentas[iSubcuenta];
                html += "<tr>";
                html += "<td width='80%' bgcolor='#FFFFFF' align='left'>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + subcuenta.codsubcuenta + ". " + subcuenta.nombre + "</td>";
                html += "<td width='20%' bgcolor='#FFFFFF' align='right'>&nbsp;" + AERPScriptCommon.formatNumber(subcuenta.importe, 2) + "&nbsp;€</td>";
                html += "</tr>";
            }
        }        
    }
    html += "</table>";
    
    html = html + "</body></html>";  
    this.ui.findChild("textEditPyG").html = html;  
}

ScriptDlg.prototype.okClicked = function() {
    if ( AERPScriptCommon.hasOwnProperty("printPreviewHtml") ) {
        thisForm.close();
    } else {
        AERPLoadExtension("alepherp.openrpt");
        var d = new Date();
        var codigo = d.toString();
        var bean = AERPScriptCommon.createBean("co_buffer_impresion");
        bean.buffer.value = this.ui.findChild("textEditActivo").html;
        bean.codigo.value = codigo;
        bean.save();
        bean = AERPScriptCommon.createBean("co_buffer_impresion");
        bean.buffer.value = this.ui.findChild("textEditPasivo").html;
        bean.codigo.value = codigo;
        bean.save();
        bean = AERPScriptCommon.createBean("co_buffer_impresion");
        bean.buffer.value = this.ui.findChild("textEditPyG").html;
        bean.codigo.value = codigo;
        bean.save();
        
        var reportName = "co_balancesituacion.xml";
        var openRPT = createOpenRPT();
        openRPT.reportName = reportName;
        openRPT.setParamValue("P_CODIGO", codigo);
        openRPT.widgetParent = thisForm;
        openRPT.filePreview();
    }
}

ScriptDlg.prototype.generarPDF = function() {    
    AERPLoadExtension("alepherp.openrpt");
    var d = new Date();
    var codigo = d.toString();
    var bean = AERPScriptCommon.createBean("co_buffer_impresion");
    bean.buffer.value = this.ui.findChild("textEditActivo").html;
    bean.codigo.value = codigo;
    bean.save();
    bean = AERPScriptCommon.createBean("co_buffer_impresion");
    bean.buffer.value = this.ui.findChild("textEditPasivo").html;
    bean.codigo.value = codigo;
    bean.save();
    bean = AERPScriptCommon.createBean("co_buffer_impresion");
    bean.buffer.value = this.ui.findChild("textEditPyG").html;
    bean.codigo.value = codigo;
    bean.save();
    
    var reportName = "co_balancesituacion.xml";
    var openRPT = createOpenRPT();
    openRPT.reportName = reportName;
    openRPT.setParamValue("P_CODIGO", codigo);
    openRPT.widgetParent = thisForm;
    openRPT.filePrintToPDF();
}

ScriptDlg.prototype.imprimir = function() {
    var html = this.ui.findChild("textEditActivo").html + this.ui.findChild("textEditPasivo").html + this.ui.findChild("textEditPyG").html;
    html = html.replace("<html><body>", "");
    html = html.replace("</html></body>", "");
    html = "<html><body>" + html + "</body></html>";
    AERPScriptCommon.printHtml(html);
}

ScriptDlg.prototype.previsualizar = function() {
    var html = this.ui.findChild("textEditActivo").html + this.ui.findChild("textEditPasivo").html + this.ui.findChild("textEditPyG").html;
    html = html.replace("<html><body>", "");
    html = html.replace("</html></body>", "");
    html = "<html><body>" + html + "</body></html>";
    AERPScriptCommon.printPreviewHtml(html);
}