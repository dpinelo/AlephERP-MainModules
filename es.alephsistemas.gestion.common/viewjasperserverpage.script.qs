Function.prototype.bind = function() {
    var func = this;
    var thisObject = arguments[0];
    var args = Array.prototype.slice.call(arguments, 1);
    return function() {
        return func.apply(thisObject, args);
    }
}

function ScriptDlg (ui) {
    loadExtension("qt.core");    
    loadExtension("qt.gui");
    this.ui = ui;
    this.ui.findChild("aERPWebView").init();
}

