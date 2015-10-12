Function.prototype.bind = function() { 
    var func = this;
    var thisObject = arguments[0];
    var args = Array.prototype.slice.call(arguments, 1);
    return function() {
        return func.apply(thisObject, args);
    }
}

function DBRecordDlg (ui) {
    this.ui = ui;
    this.settingDataFromMap = false;
    this.settingDataFromText = false;
    this.lastGeoCodeSearch = "";
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

DBRecordDlg.prototype.searchForCoords = function() {
    if ( bean.codpostal.value == "" && bean.poblacion.value == "" ) {
        return;
    }
    if ( !this.settingDataFromMap && !this.settingDataFromText ) {
        this.settingDataFromText = true;
        var direccion = bean.direccion.value + ", " + bean.codpostal.value + ", " + bean.poblacion.value + ", " + bean.paises.father.nombre.value;
        if ( this.lastGeoCodeSearch != direccion ) {
            this.lastGeoCodeSearch = direccion;
            var coordenadas = AERPScriptCommon.coordinates(direccion);
            if ( coordenadas.error == "" ) {
                bean.coordenadas.value = coordenadas[0].coordinates;
            }
        }
        this.settingDataFromText = false;
    }
}

DBRecordDlg.prototype.db_direccionLostFocus = function() {
    this.searchForCoords();
}

DBRecordDlg.prototype.db_codpostalLostFocus = function() {
    this.searchForCoords();
}

DBRecordDlg.prototype.db_poblacionLostFocus = function() {
    this.searchForCoords();
}

DBRecordDlg.prototype.dbMapPositionAfterChangeCoords = function(markName, coordinates) {
    if ( markName == thisForm.dbMapPosition.title && !this.settingDataFromText && !this.settingDataFromMap ) {
        this.settingDataFromMap = true;
        bean.direccion.value = thisForm.dbMapPosition.engineValue("route") + ", " + thisForm.dbMapPosition.engineValue("street_number");
        bean.codpostal.value = thisForm.dbMapPosition.engineValue("postal_code");
        bean.poblacion.value = thisForm.dbMapPosition.engineValue("locality,political");
        var provincia = thisForm.dbMapPosition.engineValue("administrative_area_level_2,political");
        var beanProvincia = AERPScriptCommon.bean("provincias", "lower(provincia) like '" + provincia.toLowerCase() + "'");
        if ( beanProvincia != undefined ) {
            bean.idprovincia.value = beanProvincia.idprovincia.value;
        }
        var pais = thisForm.dbMapPosition.engineValue("country,political");
        var beanPais = AERPScriptCommon.bean("paises", "lower(nombre) like '" + pais.toLowerCase() + "'");
        if ( beanPais != undefined ) {
            bean.codpais.value = beanPais.codpais.value;
        }
        this.settingDataFromMap = false;
    }
}
