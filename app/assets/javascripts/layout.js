$(document).ready(function() {
    $('#search-bar-categories').select2({
        width : "resolve"
    });
    if ($(window).width() > 700) {
        $('#search-bar-categories').next(".select2-container").show();
    }
    else {
        $('#search-bar-categories').next(".select2-container").hide();
    }
});