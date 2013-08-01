// FLASH NOTICE ANIMATION
var fade_flash = function() {
    $(".ajax.flash.notice").delay(5000).fadeOut("slow");
    $(".ajax.flash.alert").delay(5000).fadeOut("slow");
    $(".ajax.flash.error").delay(5000).fadeOut("slow");
};
fade_flash();

var show_ajax_message = function(msg, type) {
    $("#messages").html('<div class="ajax flash '+type+'">'+msg+'</div>');
    fade_flash();
};

$(document).ajaxComplete(function(event, request) {
    var msg = request.getResponseHeader('X-Message');
    var type = request.getResponseHeader('X-Message-Type');
    if (msg) {
      show_ajax_message(msg, type); //use whatever popup, notification or whatever plugin you want
    }
});