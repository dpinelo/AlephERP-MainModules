({

valorPorDefecto: function(name) {
    var reg = this.empresasvalorespordefecto.childByField("nombre", name);
    if ( reg != null ) {
        return reg.value.value;
    }
    return "";
}

})