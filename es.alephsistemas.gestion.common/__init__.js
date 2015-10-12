/*!
  Para proporcionar mecanismos de herencia en Javascript
  http://www.ajaxpath.com/javascript-inheritance
  */
Class = function () { };

Class.prototype.construct = function() {};

Class.extend = function(def) {
        var classDef = function() {
            if (arguments[0] !== Class) { this.construct.apply(this, arguments); }
        };

        var proto = new this(Class);
        var superClass = this.prototype;

        for (var n in def) {
            var item = def[n];
            if (item instanceof Function) item.$ = superClass;
            proto[n] = item;
        }

        classDef.prototype = proto;

        //Give this new class the same static extend method
        classDef.extend = this.extend;
        return classDef;
};

/*!
  http://www.mojavelinux.com/articles/javascript_hashes.html
  */
Hash = function()
{
    this.length = 0;
    this.items = [];
    for (var i = 0; i < arguments.length; i += 2) {
        if (typeof(arguments[i + 1]) != 'undefined') {
            this.items[arguments[i]] = arguments[i + 1];
            this.length++;
        }
    }

    this.removeItem = function(in_key)
    {
        var tmp_previous;
        if (typeof(this.items[in_key]) != 'undefined') {
            this.length--;
            var tmp_previous = this.items[in_key];
            delete this.items[in_key];
        }

        return tmp_previous;
    }

    this.item = function(in_key) {
        return this.items[in_key];
    }

    this.setItem = function(in_key, in_value)
    {
        var tmp_previous;
        if (typeof(in_value) != 'undefined') {
            if (typeof(this.items[in_key]) == 'undefined') {
                this.length++;
            }
            else {
                tmp_previous = this.items[in_key];
            }

            this.items[in_key] = in_value;
        }

        return tmp_previous;
    }

    this.hasItem = function(in_key)
    {
        return typeof(this.items[in_key]) != 'undefined';
    }

    this.clear = function()
    {
        for (var i in this.items) {
            delete this.items[i];
        }

        this.length = 0;
    }
    this.toArray = function()
    {
        var superArray = [];
        superArray[0] = this.length;
        superArray[1] = this.items;
        return superArray;
    }
    this.fromArray = function(dataArray)
    {
        this.length = dataArray[0];
        this.items = dataArray[1];
    }
}

/*
CartesianProduct = function()
{
    this.codes = [];
    this.pos = 0;
    this.result = [];

    this.combinations = function(arr)
    {
        if ( typeOf(arr) == "array" && arr.length > 0 ) {
            var firstElement = arr[0];
            if ( typeOf(firstElement) == "array" ) {
                for( var i = 0 ; i < firstElement.length ; i++ ) {
                    var tmp = arr.clone();
                    this.codes[this.pos] = firstElement[i];
                    tmp.shift();
                    this.pos++;
                    this.combinations(tmp);
                }
            }
        } else {
            debug(this.codes);
            this.result[this.result.length] = this.codes.clone();
        }
        this.pos--;
    }
}

Object.prototype.clone = function() {
  var newObj = (this instanceof Array) ? [] : {};
  for (i in this) {
    if (i == 'clone') continue;
    if (this[i] && typeof this[i] == "object") {
      newObj[i] = this[i].clone();
    } else newObj[i] = this[i]
  } return newObj;
};
*/

/*!
  http://javascript.crockford.com/remedial.html
  */
typeOf = function (value) {
    var s = typeof value;
    if (s === 'object') {
        if (value) {
            if (typeof value.length === 'number' &&
                    !(value.propertyIsEnumerable('length')) &&
                    typeof value.splice === 'function') {
                s = 'array';
            }
        } else {
            s = 'null';
        }
    }
    return s;
}


isEmpty = function(o) {
    var i, v;
    if (typeOf(o) === 'object') {
        for (i in o) {
            v = o[i];
            if ( typeof v !== "undefined" && typeOf(v) !== 'function') {
                return false;
            }
        }
    }
    return true;
}

if (!String.prototype.entityify) {
    String.prototype.entityify = function () {
        return this.replace(/&/g, "&amp;").replace(/</g,
            "&lt;").replace(/>/g, "&gt;");
    };
}

if (!String.prototype.quote) {
    String.prototype.quote = function () {
        var c, i, l = this.length, o = '"';
        for (i = 0; i < l; i += 1) {
            c = this.charAt(i);
            if (c >= ' ') {
                if (c === '\\\\' || c === '"') {
                    o += '\\\\';
                }
                o += c;
            } else {
                switch (c) {
                case '\\b':
                    o += '\\\\b';
                    break;
                case '\\f':
                    o += '\\\\f';
                    break;
                case '\\n':
                    o += '\\\\n';
                    break;
                case '\\r':
                    o += '\\\\r';
                    break;
                case '\\t':
                    o += '\\\\t';
                    break;
                default:
                    c = c.charCodeAt();
                    o += '\\\\u00' + Math.floor(c / 16).toString(16) +
                        (c % 16).toString(16);
                    break;
                }
            }
        }
        return o + '"';
    };
}

if (!String.prototype.supplant) {
    String.prototype.supplant = function (o) {
        return this.replace(/{([^{}]*)}/g,
            function (a, b) {
                var r = o[b];
                return typeof r === 'string' || typeof r === 'number' ? r : a;
            }
        );
    };
}

if (!String.prototype.trim) {
    String.prototype.trim = function () {
        return this.replace(/^\\s*(\\S*(?:\\s+\\S+)*)\\s*$/, "$1");
    };
}

isValidDate = function(d) {
    if ( Object.prototype.toString.call(d) === "[object Date]" ) {
        // it is a date
        if ( isNaN( d.getTime() ) ) { // d.valueOf() could also work
            // date is not valid
            return false;
        } else {
            // date is valid
            return true;
        }
    }
    return false;
}

// Se mantiene por compatibilidad con aplicaciones ya instaladas
ejercicioActual = function() {
    if ( typeof PERPScriptCommon.appVersion == 'undefined' ) {
        return 8;
    } else {
        return AERPScriptCommon.envVar("idejercicio");
    }
}

idejercicioActual = function() {
    if ( typeof PERPScriptCommon.appVersion == 'undefined' ) {
        return 8;
    } else {
        return AERPScriptCommon.envVar("idejercicio");
    }
}

idempresaActual = function() {
    /* Leemos de las variables de entorno del usuario, la empresa actualmente seleccionada */
    if ( typeof PERPScriptCommon.appVersion == 'undefined' ) {
        return PERPScriptCommon.envVar("idempresa");
    } else {
        return AERPScriptCommon.envVar("idempresa");
    }
}

empresaActual = function() {
    var codEmpresa = AERPScriptCommon.envVar("idempresa");
    var beanEmpresa = AERPScriptCommon.bean("empresas", "id=" + codEmpresa);
    return beanEmpresa;
}

coddivisaPorDefecto = function() {
    var beanEmpresa = empresaActual();
    return beanEmpresa.fieldValue("coddivisa");
}

calcularDC = function(banco, sucursal, cuenta) {
    debug("Entra en calcularDC");
    var pesos= new Array(6,3,7,9,10,5,8,4,2,1);
    var result ='';
    var iTemp =0;
    var primeraParte = banco + "" + sucursal;
    if ( primeraParte.length != 8 || cuenta.length != 10 ) {
        return "";
    }        
    for ( var n = 0 ; n <= 7 ; n++ ) {
         iTemp  = iTemp + Number(primeraParte.substr(7 - n, 1)) * pesos[n];
    }
    result = 11 - iTemp % 11;
    if ( result > 9 ) {
        result = 1 - result % 10;
    }
    iTemp=0;
    for ( var n = 0 ; n <=9 ; n++ ) {
        iTemp  = iTemp + Number(cuenta.substr(9 - n, 1)) * pesos[n];
    }
    iTemp = 11 - (iTemp % 11);
    if ( iTemp > 9 ) {
        iTemp = 1 - (iTemp % 10);
    }
    result = result * 10 + iTemp;
    if ( result < 10 ) {
        result = "0" + result;
    }
    return result;
 }
 
Function.prototype.bind = function() { 
    var func = this;
    var thisObject = arguments[0];
    var args = Array.prototype.slice.call(arguments, 1);
    return function() {
        return func.apply(thisObject, args);
    }
}

/**
Las l?neas de art?culos de pedidos de clientes/proveedores, albaranes o facturas, comparten mucho c?digo en com?n.
Utilizamos "Prototype chaining" de Javascript para simular herencia, y de esa manera, no reescribir c?digo
*/
function DBRecordDlgLineasArticulos (ui) {
    loadExtension("qt.core");
    loadExtension("qt.gui");
    this.ui = ui;
    
    if ( bean.dbState == BaseBean.INSERT ) {
        thisForm.db_recargo.visible = false;
    } else {
        thisForm.db_recargo.visible = bean.fieldValue("incluirrecargoequivalencia");
    }
}

DBRecordDlgLineasArticulos.prototype.validate = function() {
    return true;
}

DBRecordDlgLineasArticulos.prototype.beforeSave = function() {
    return true;
}

DBRecordDlgLineasArticulos.prototype.beanSaved = function() {
    return;
}

DBRecordDlgLineasArticulos.prototype.beforeNavigate = function() {
    return true;
}

DBRecordDlgLineasArticulos.prototype.afterNavigate = function() {
    return;
}

DBRecordDlgLineasArticulos.prototype.updateIVA = function() {
    var beanIVA = thisForm.db_idimpuesto.selectedBean;
    if ( beanIVA != null ) {
        bean.setFieldValue("iva", beanIVA.fieldValue("iva"));
        bean.setFieldValue("recargo", beanIVA.fieldValue("recargo"));
    }        
}

DBRecordDlgLineasArticulos.prototype.updateIRPF = function() {
    var beanIRPF = thisForm.db_idimpuesto_irpf.selectedBean;
    if ( beanIRPF != null ) {
        bean.setFieldValue("irpf", beanIRPF.fieldValue("irpf"));
    }        
}

DBRecordDlgLineasArticulos.prototype.incluirrecargoequivalenciaValueModified = function() {
    thisForm.db_recargo.visible = thisForm.db_incluirrecargoequivalencia.checked;
}

DBRecordDlgLineasArticulos.prototype.idarticuloValueModified = function () {
    if ( bean.fieldValue("idarticulo") > 0 ) {
        if ( bean.fieldValue("idimpuesto") == null || bean.fieldValue("idimpuesto") == 0 ) {
            bean.setFieldValue("idimpuesto", bean.fatherFieldValue("articulos", "idimpuestocompra"));
            var impuestoCompra = bean.father("articulos").field("idimpuestocompra").relation("impuestos").father();
            bean.setFieldValue("iva", impuestoCompra.fieldValue("iva"));
            bean.setFieldValue("importesindto", bean.fatherFieldValue("articulos", "pvp"));
        } else {
            if ( bean.fatherFieldValue("articulos", "idimpuestocompra" ) != bean.fieldValue("idimpuesto") ) {
                var ret = QMessageBox.question(this.ui, "AlephERP", "¿Desea utilizar el IVA del nuevo artículo?",
                    QMessageBox.StandardButtons(QMessageBox.Yes, QMessageBox.No));
                if ( ret == QMessageBox.Yes ) {
                    bean.setFieldValue("idimpuesto", bean.fatherFieldValue("articulos", "idimpuestocompra"));
                    bean.setFieldValue("iva", bean.fatherFieldValue("articulos", "iva"));
                    bean.setFieldValue("importesindto", bean.fatherFieldValue("articulos", "pvp"));
                }
            }
        }
    }
}
