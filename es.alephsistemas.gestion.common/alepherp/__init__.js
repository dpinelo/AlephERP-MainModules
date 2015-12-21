__setupPackage__("alepherp");

Function.prototype.bind = function() { 
    var func = this;
    var thisObject = arguments[0];
    var args = Array.prototype.slice.call(arguments, 1);
    return function() {
        return func.apply(thisObject, args);
    }
}

debug("Iniciando alepherp scripts comunes.");
AERPLoadJS(AERPScriptFunctionsPath() + "/alepherp/ivafunctions.js");
AERPLoadJS(AERPScriptFunctionsPath() + "/alepherp/lineasserviciosdocumentosgestion.js");
AERPLoadJS(AERPScriptFunctionsPath() + "/alepherp/lineasarticulosdocumentosgestion.js");
AERPLoadJS(AERPScriptFunctionsPath() + "/alepherp/documentosgestion.js");
