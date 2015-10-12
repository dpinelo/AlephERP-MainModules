Function.prototype.bind = function() {
  var func = this;
  var thisObject = arguments[0];
  var args = Array.prototype.slice.call(arguments, 1);
  return function() {
    return func.apply(thisObject, args);
  }
}

function DBFormDlg (ui) {
    this.ui = ui;
    thisForm.visibleButtons = DBForm.EDIT | DBForm.DELETE | DBForm.EXIT;
}
