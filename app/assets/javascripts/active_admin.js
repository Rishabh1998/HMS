//= require arctic_admin/base
//= require activeadmin_addons/all
//= require jquery
//= require jquery_ujs

$( document ).ready(function() {

    let value = ""
    if (window.location.href.includes('?'))
        value = window.location.href.split("?")[1].split("=")[1]

    if (value != ""){
        $("#booking_status").val(value).change();
    }

    if ($('.custom_buttons')[0] != null){

        $('#main_content').prepend($('.custom_buttons'))
    }

});
