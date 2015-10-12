Function.prototype.bind = function() {
  var func = this;
  var thisObject = arguments[0];
  var args = Array.prototype.slice.call(arguments, 1);
  return function() {
    return func.apply(thisObject, args);
  }
}

function DBFormDlg (ui) {
    AERPLoadExtension("qt.gui");
    this.ui = ui;

    var roles = AERPScriptCommon.roles();
    this.userIsAdmin = false;
    for ( var i = 0 ; i < roles.length ; i++ ) {
        if (roles[i] == "central") {
            this.userIsAdmin = true;
        }
    }
    
    if ( this.userIsAdmin ) {
    }
}

