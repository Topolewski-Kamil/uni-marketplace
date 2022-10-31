$(".listings.review_list").ready(function() {
    if ($("#review-listing-list-container").scrollTop($("#review-listing-list-container .clicked")).offset() != undefined) {
        $("#review-listing-list-container").scrollTop($("#review-listing-list-container .clicked").offset().top - 315)
    }

    $("#invalid-price").hide()
    $("#invalid-post-code").hide()
    $("#invalid-title").hide()
    $('#title-limit').hide()

    if ($('#location').val() == "Sheffield") show('#post-code-input')
    else hide('#post-code-input')

    $(".required-details").each(function(index) {
        if($(this).val()=="" || !validPostCode() || !validPrice() || !checkboxesChecked()) $("#edit-button").prop("disabled", true)
    });

    $(".required-details, .required-options, #post-code, #price").change(function() {
        $("#edit-button").prop("disabled", false)
        $(".required-details").each(function(index) {
            if($(this).val()=="" || !validPostCode() || !validPrice() || !checkboxesChecked()) $("#edit-button").prop("disabled", true)
      });
    })    

    $("#images, #listing_terms").change(function(){ // Enable 'Submit' button when terms checkbox is ticked and less than 5 photos chosen
        var $fileUpload = $("input[type='file']");
        var imgCount = parseInt($fileUpload.get(0).files.length)
        var imagesSize = 0
        var illegalExtension = false
        const MAX_UPLOAD_SIZE = 500
        const MAX_IMAGE_COUNT = 5
        const ALLOWED_FILE_EXTENSIONS = ['jpg', 'png', 'jpeg'];
        
        $.each($fileUpload[0].files, function(index, value){ // calculate sum of image sizes
            imagesSize += value.size / 1024
            if ($.inArray(value.name.split('.').pop().toLowerCase(), ALLOWED_FILE_EXTENSIONS) == -1) illegalExtension = true
        });

        if (illegalExtension){ // display error message if any condition fail
            $("#error-message").html("Ilegal file type. Allowed formats: png, jpg.").addClass("text-danger")
        } else if (imgCount > MAX_IMAGE_COUNT) { 
            $("#error-message").html("MAXIMUM IMAGE COUNT EXCEEDED: " + imgCount + "/" + MAX_IMAGE_COUNT).addClass("text-danger")
        } else if (imagesSize > MAX_UPLOAD_SIZE) {
            $("#error-message").html("MAXIMUM UPLOAD SIZE EXCEEDED:" + imagesSize.toFixed(1) + "KB/" + MAX_UPLOAD_SIZE + "KB").addClass("text-danger")
        } else $("#error-message").html("");

        if ((imgCount <= MAX_IMAGE_COUNT) && imagesSize <= MAX_UPLOAD_SIZE && !illegalExtension) // disable/enable submit button
            $("#edit-button").prop("disabled", false) 
        else $("#edit-button").prop("disabled", true)
    });    

    $('#location').change(function() { // location validation
        if ($('#location').val() == "Sheffield") show('#post-code-input')
        else{
            hide('#post-code-input')
            $("#post-code").val('')
        } 
    });

    $('#title-field').keyup(function(event) { // description character limit error
        var length =  $('#title-field').val().length;
        if (length == 250) $('#title-limit').show()
        else $('#title-limit').hide()
    });

    $('#description-field').keyup(function(event) { // description character limit error
        var length =  $('#description-field').val().length;
        if (length != 0) $('#description-length-left').text('Character count: ' + length + '/2000');
        else $('#description-length-left').text('');
    });

    $('#price').keyup(function(event) { // invalid price error
        if (!validPrice()) $("#invalid-price").show();
        else $("#invalid-price").hide();
    });

    $('#price').change(function(event) { // price decimal point validator
        var price = parseFloat($('#price').val())
        $("#price").val(price.toFixed(2))
    });

    $('#post-code').keyup(function(event) { // description character limit error
        if (!validPostCode()) $("#invalid-post-code").show();
        else $("#invalid-post-code").hide();
    });

    function validPostCode(){
        var postCode = $('#post-code').val()
        if (/^[Ss]{1}\d{1,2}/.test(postCode) || postCode == '' || $('#location').val() != "Sheffield") return true
        return false
    }

    function validPrice(){
        if ($('#price').val() < 0 || $('#price').val() > 10000) return false
        return true
    }

    function checkboxesChecked(){
        var anyChecked = false
        $(".required-options").each(function(index) {
            if($(this).prop("checked")) anyChecked = true
        });
      return anyChecked
    }

    function show(element){
        $(element).fadeIn()
    }
    function hide(element){
        $(element).hide()
    }
})