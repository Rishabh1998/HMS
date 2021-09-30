//= require arctic_admin/base
//= require activeadmin_addons/all

$( document ).ready(function() {

    let value = window.location.href.split("?")[1].split("=")[1]

    if (value != null){
        $("#booking_status").val(value).change();
    }
        

});