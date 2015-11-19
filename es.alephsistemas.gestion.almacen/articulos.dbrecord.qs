Function.prototype.bind = function() {
    var func = this;
    var thisObject = arguments[0];
    var args = Array.prototype.slice.call(arguments, 1);
    return function() {
        return func.apply(thisObject, args);
    }
}

function DBRecordDlg (ui) {
    loadExtension("qt.core");
    loadExtension("qt.gui");
    this.ui = ui;

    // Obtenemos y guardamos los objetos más habituales de la UI
    this.tbDatos = this.ui.findChild("tbDatos");
    this.tbCompras = this.ui.findChild("tbCompras");
    this.tbVentas = this.ui.findChild("tbVentas");
    this.tbStocks = this.ui.findChild("tbStocks");
    this.tbObservaciones = this.ui.findChild("tbObservaciones");
    this.tbContabilidad = this.ui.findChild("tbContabilidad");
    this.tbInstancias = this.ui.findChild("tbInstancias");
    this.tbDatos.checked = true;
    this.swFichas = this.ui.findChild("swFichas");
    this.swFichas.setCurrentWidget(this.ui.findChild("pageDatos"));
                
    this.tbDatos.clicked.connect(this, "showPage");
    this.tbCompras.clicked.connect(this, "showPage");
    this.tbVentas.clicked.connect(this, "showPage");
    this.tbStocks.clicked.connect(this, "showPage");
    this.tbObservaciones.clicked.connect(this, "showPage");
    this.tbContabilidad.clicked.connect(this, "showPage");
    this.tbInstancias.clicked.connect(this, "showPage");

    var beanEmpresaActual = empresaActual();
    if ( beanEmpresaActual.fieldValue("contintegrada") == false ) {
        this.tbContabilidad.enabled = false;
    }
    
    if ( bean.dbState == BaseBean.INSERT ) {
        // Si la subfamilia tiene predefinidas algunas caracteristicas, las agregamos...
        if ( bean.idsubfamilia.value > 0 ) {
            var caracteristicas = AERPScriptCommon.beans("articuloscaracteristicasdefiniciones", "idsubfamilia=" + bean.idsubfamilia.value + " or idfamilia=" + bean.subfamiliasarticulos.father.idfamilia.value, "");
            for ( var i = 0 ; i < caracteristicas.length ; i++ ) {
                var caracteristica = bean.articuloscaracteristicasvalores.newChild();
                caracteristica.idcaracteristica.value = caracteristicas[i].id.value;
            }
        }
    }
}

DBRecordDlg.prototype.showPage = function() {
    if ( this.tbDatos.checked ) {
        this.swFichas.setCurrentWidget(this.ui.findChild("pageDatos"));
    } else if ( this.tbCompras.checked ) {
        this.swFichas.setCurrentWidget(this.ui.findChild("pageCompras"));
    } else if ( this.tbVentas.checked ) {
        this.swFichas.setCurrentWidget(this.ui.findChild("pageVentas"));
    } else if ( this.tbStocks.checked ) {
        this.swFichas.setCurrentWidget(this.ui.findChild("pageStocks"));
    } else if ( this.tbObservaciones.checked ) {
        this.swFichas.setCurrentWidget(this.ui.findChild("pageObservaciones"));
    } else if ( this.tbContabilidad.checked ) {
        this.swFichas.setCurrentWidget(this.ui.findChild("pageContabilidad"));
    } else if ( this.tbInstancias.checked ) {
        this.swFichas.setCurrentWidget(this.ui.findChild("pageInstancias"));
    }
}

DBRecordDlg.prototype.validate = function() {
    return true;
}

DBRecordDlg.prototype.beforeSave = function() {
    return true;
}

DBRecordDlg.prototype.beanSaved = function() {
    return;
}

DBRecordDlg.prototype.beforeNavigate = function() {
    return true;
}

DBRecordDlg.prototype.afterNavigate = function() {
    return;
}


