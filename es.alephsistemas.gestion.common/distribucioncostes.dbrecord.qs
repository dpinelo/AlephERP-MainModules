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
    
    this.swFichas = this.ui.findChild("swFichas");
    this.pbAniadirMultiple = this.ui.findChild("pbAniadirMultiple");
    this.pbAniadirSubcentros = this.ui.findChild("pbAniadirSubcentros");
    this.pbCancelar = this.ui.findChild("pbCancelar");
    
    this.swFichas.setCurrentWidget(this.ui.findChild("pageDetail"));
    
    this.pbAniadirSubcentros.clicked.connect(this, "showAniadirMultiple");
    this.pbCancelar.clicked.connect(this, "cancelarAniadir");
    this.pbAniadirMultiple.clicked.connect(this, "aniadirSubcentros");
}

DBRecordDlg.prototype.validate = function() {
    var lineasCostes = bean.relationChildsCount("lineasdistribucioncostes");
    if ( lineasCostes == 0 ) {
        var ret = AERPMessageBox.question("No ha introducido ningún desglose de Subcentros de costes. ¿Desea guardar aún así?",
            AERPMessageBox.Yes | AERPMessageBox.No);
        if ( ret == AERPMessageBox.No ) {
            return false;
        }
    }
    // Se comprueba que los cálculos de costes coinciden con el neto.
    if ( bean.fieldValue("totalporcentajes") != 100 ) {
        var ret = AERPMessageBox.question("Los porcentajes de los subcentros de coste no suma 100. Esto puede desvirtuar la distribución. ¿Está seguro de querer continuar?",
            AERPMessageBox.Yes | AERPMessageBox.No);
        if ( ret == AERPMessageBox.No ) {
            return false;
        }            
    }
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

DBRecordDlg.prototype.showAniadirMultiple = function() {
    this.swFichas.setCurrentWidget(this.ui.findChild("pageSubcentros"));
}

DBRecordDlg.prototype.cancelarAniadir = function() {
    this.swFichas.setCurrentWidget(this.ui.findChild("pageDetail"));
}

DBRecordDlg.prototype.aniadirSubcentros = function() {
    var beansSubcentros = thisForm.tvSubcentros.checkedBeans;
    var relationLineas = bean.relation("lineasdistribucioncostes");
    var numSubcentros = 0;
    for ( var i = 0 ; i < beansSubcentros.length ; i++ ) {
        if ( beansSubcentros[i].metadata.tableName == "subcentroscoste" ) {
            numSubcentros++;
        }
    }
    for ( var i = 0 ; i < beansSubcentros.length ; i++ ) {
        if ( beansSubcentros[i].metadata.tableName == "subcentroscoste" ) {
            var beanLinea = relationLineas.newChild();
            beanLinea.idcentro.value = beansSubcentros[i].idcentrocoste.value;
            beanLinea.descripcioncentro.value = beansSubcentros[i].centroscoste.father.nombre.value;
            beanLinea.idsubcentro.value = beansSubcentros[i].id.value;
            beanLinea.descripcionsubcentro.value = beansSubcentros[i].nombre.value;
            beanLinea.pordistribucioncoste.value = (100 / numSubcentros);
        }
    }
    this.swFichas.setCurrentWidget(this.ui.findChild("pageDetail"));
}

