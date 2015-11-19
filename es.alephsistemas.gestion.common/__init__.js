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

/**
* Comprueba si hay datos cargados en la instancia (al menos algún dato mínimo...) y si no es así, inicia la app con datos
*/
precargarDatosSiNecesario = function() {
    
    // ¿Hay alguna divisa definida? Si no es así, creamos al menos EUROS
    var numDivisas = AERPScriptCommon.sqlCount("divisas", "");
    if ( numDivisas == 0 ) {
        var divisa = AERPScriptCommon.createBean("divisas");
        divisa.coddivisa.value = "EUR";
        divisa.descripcion.value = "Euros";
        divisa.save();
    }

    // Comprobemos primero que hay definida una empresa y un ejercicio fiscal actual, ya que si no,
    // habrá que crearlos. Se utiliza la función sqlCount del objeto de entorno de script AERPScriptCommon,
    // que dispone de funciones de ayuda al programador QS.
    var numEmpresas = AERPScriptCommon.sqlCount("empresas", "");
    if ( numEmpresas == -1 ) {
        AERPMessageBox.information("Ha ocurrido un error en el primer acceso a base de datos. No existe la tabla 'empresas'. La importación no se ha efectuado correctamente. No se puede iniciar la aplicación.");
        quitApplication();
        return;    
    } else if ( numEmpresas == 0 ) {
        AERPMessageBox.information("No hay definida ninguna empresa en el sistema. Se crearán algunos datos por defecto.");
        
        var empresa = AERPScriptCommon.createBean("empresas");
        empresa.nombre.value = "Empresa de pruebas - EDÍTEME";
        empresa.cifnif.value = "87654321X";
        empresa.counter_prefix.value = "EP";
        empresa.coddivisa.value = "EUR";
        empresa.contabilidadcostes.value = false;
        var ejercicio = empresa.ejercicios.newChild();
    }
}
 
 
Function.prototype.bind = function() { 
    var func = this;
    var thisObject = arguments[0];
    var args = Array.prototype.slice.call(arguments, 1);
    return function() {
        return func.apply(thisObject, args);
    }
}

