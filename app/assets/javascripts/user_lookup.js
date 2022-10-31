// for disabling moderator button after sending a request (Revoke / Make)
var moderator_loading = false;

function toggle_loading(on) {
    if (on) {
        $('#lookup_spinner').show(); //show loading animation
        moderator_loading = true
    } else {
        $('#lookup_spinner').hide();
        $('button').blur(); //disable focus on buttons
        moderator_loading = false
    }
}

// hide loading animation
$('.moderator').ready(function() {
    $('#lookup_spinner').hide();
    
    // rewire Enter press to do ajax and not submit form
    $('#lookup_form').on("keyup keypress", function(event) {
        if (event.keyCode === 13) {
            event.preventDefault();
            user_search();
            return false;
        }
    });
});


//ajax request to find users
function user_search() {
    if (moderator_loading)
        return

    toggle_loading(true);

    let query_inp = $('#query_input').val();

    $.ajax({
        url: 'users/search',
        dataType: 'json',
        type: 'get',
        data: {query: query_inp},
        success: function(data) {
            //if success, build table with results
            parse_search_result(data);
        },
        error: function(data) {alert("Something went wrong.")}
    }).always(() => {
        toggle_loading(false);
    });
}

// parse search results and build a table
function parse_search_result(data) {
    let matches_found = data.matches != null

    //hide stuff before showing new results (popovers, table rows, etc)
    $('.popover').each(function() {
        $(this).popover('hide');
    });
    $('#zero_matches_msg').remove();
    $('#number_of_matches').remove();
    $('#user_lookup_tbody').empty();

    if (matches_found) {
        //message with number of matching results
        let n_results = '<p  id="number_of_matches" class="text-muted text-center mt-4">' +
                        '   <b>' + data.matches.length + '</b>' +
                        '   result(s)' +
                        '</p>'
        
        $('#lookup_form').after(n_results);

        //add rows
        data.matches.forEach(element => build_new_row(element));

        // enable email popovers over names
        $('[data-toggle="popover"]').popover()
        
    } else {
        //message about zero matches
        let mo_matches_msg = '<p id="zero_matches_msg" class="text-muted text-center mt-4">No matching users found</p>'
        $('#lookup_form').after(mo_matches_msg);
    }
}


//builds a sungle row and appends to the table
function build_new_row(user) {
    let newRow =    '<tr>' +
                    '   <td class="align-middle">' +
                    '       <span data-toggle="popover" data-placement="top" data-content="' + user.email + '">' + user.fn + ' ' + user.sn + '</span></td>' + //name
                    '   <td class="align-middle">' + user.username + '</td>' + //username
                    '   <td class="align-middle text-center">' +
                    '       <a href="/users/' + user.id + '" class="card-link">Profile</a>' + //profile link
                    '   </td>' +
                    '   <td class="align-middle text-right">' +
                    '       <a  href="#" id="moderator_link" class="card-link"></a>' + //revoke or grant moderator link
                    '   </td>' +
                    '</tr>'
    

    $('#user_lookup_tbody').append(newRow);

    //set moderator link (colour,text and assigned function)
    let mod_link = $('#moderator_link');
    if (user.moderator) {
        mod_link.addClass("text-danger");
        mod_link.text("Revoke moderator");
        mod_link.attr("onclick", "revoke_moderator(event)");

    } else {
        mod_link.addClass("text-success");
        mod_link.text("Make moderator");
        mod_link.attr("onclick", "grant_moderator(event)");
    }

    //add attributes to the link element
    mod_link.attr("id", user.id + "_moderator_link");
    mod_link.attr("data_arg", user.id);
    mod_link.attr("data_fn", user.fn);
}


// ajax post request to revoke moderator previlage  
function revoke_moderator(e) {
    if (moderator_loading)
        return

    

    user_id = e.currentTarget.attributes.data_arg.value;
    user_fn = e.currentTarget.attributes.data_fn.value;
    //check if un-modding yourself
    let ownID = $('#lookup_users').attr('data_id')
    if (user_id == ownID) {
        let r = confirm("You're about to remove moderator previlages from yourself.\n\nAre you sure?");
        if (!r)
            return
    }
    else{
        let r = confirm("You're about to remove moderator previlages from " + user_fn + ".\n\nAre you sure?");
        if (!r)
            return
    }

    toggle_loading(true);
    
    $.ajax({
        url: '/users/revoke_moderator',
        dataType: 'json',
        type: 'post',
        data: {id: user_id},
        success: function(data) {
            // on success - change revoke link to grant link and change function
            let mod_link = $('#' + data.id + '_moderator_link');
            mod_link.removeClass("text-danger");
            mod_link.addClass("text-success");
            mod_link.text("Make moderator");
            mod_link.attr("onclick", "grant_moderator(event)"); //dont change to mod_link.click(...) !
        },
        error: function(data) {alert("Something went wrong.")}
    }).always(() => {
        toggle_loading(false);
    })
}


// same as above but for granting mod previlage
function grant_moderator(e) {
    if (moderator_loading)
        return
    
    toggle_loading(true);
    user_fn = e.currentTarget.attributes.data_fn.value;

    let r = confirm("You're about to grant moderator previlages to "  + user_fn + ".\n\nAre you sure?");
    if (!r)
        return

    user_id = e.currentTarget.attributes.data_arg.value;
    $.ajax({
        url: '/users/grant_moderator',
        dataType: 'json',
        type: 'post',
        data: {id: user_id},
        success: function(data) {
            let mod_link = $('#' + data.id + '_moderator_link');
            mod_link.removeClass("text-success");
            mod_link.addClass("text-danger");
            mod_link.text("Revoke moderator");
            mod_link.attr("onclick", "revoke_moderator(event)"); //dont change to mod_link.click(...) !
        },
        error: function(data) {alert("Something went wrong.")}
    }).always(() => {
        toggle_loading(false);
    })
}


function show_moderators() {
    if (moderator_loading)
        return

    toggle_loading(true);

    $.ajax({
        url: '/users/get_moderators',
        dataType: 'json',
        type: 'get',
        success: function(data) {
            parse_search_result(data);
        },
        error: function(data) {alert("Something went wrong.")}
    }).always(() => {
        toggle_loading(false);
    })
}