var edit_listing_loading = false

// hide loading animation
$('.moderator').ready(function() {
  $('#edit_listing_lookup_spinner').hide();
    
  // rewire Enter press to do ajax and not submit form
  $('#listing_search_form').on("keyup keypress", function(event) {
    if (event.keyCode === 13) {
      event.preventDefault();
      listing_search();
      return false;
    }
  });
});

function toggle_edit_listing_loading(on) {
  if (on) {
      $('#edit_listing_lookup_spinner').show(); //show loading animation
      edit_listing_loading = true
  } else {
      $('#edit_listing_lookup_spinner').hide();
      $('button').blur(); //disable focus on buttons
      edit_listing_loading = false
  }
}

//ajax request to find listings
function listing_search() {
  if (edit_listing_loading)
      return

  toggle_edit_listing_loading(true);
  $.ajax({
    url: 'search_listing',
    dataType: 'json',
    type: 'get',
    data: {title: $('#edit-listings-title_input').val()},
    success: function(data) {
      //if success, build table with results
      parse_listings_search_result(data);
    },
    error: function(data) {alert("Something went wrong.")}
  }).always(() => {
    toggle_edit_listing_loading(false);
  })
}

// parse search results and build a table
function parse_listings_search_result(data) {
  //hide stuff before showing new results (popovers, table rows, etc)
    $('#listing_tbody').empty();
    $('#listings_zero_matches_msg').remove();
    $('#listings_number_of_matches').remove();
    if (data.matches.length != 0) {

        let num_results = '<p  id="listings_number_of_matches" class="text-muted text-center mt-4">' +
                          '   <b>' + data.matches.length + '</b>' +
                          '   result(s) found' +
                          '</p>'

        $('#listing_search_form').after(num_results);

        //add rows
        data.matches.forEach(element => listings_build_new_row(element));
        
    } else {
        //message about zero matches 
        let no_matches_msg = '<p id="listings_zero_matches_msg" class="text-muted text-center mt-4">No matching listings found</p>'
        $('#listing_search_form').after(no_matches_msg);
    }
}

function listings_build_new_row(listing) {
    let newRow =    '<tr>' +
                    '   <td class="align-middle mx-3"><b>' + listing.title +  '</td>' + //title
                    '   <td class="align-middle text-right mx-3">' +
                    '       <a class="btn btn-primary rounded-0" href="/listings/'+ listing.listing_id +'/edit">Edit</a>' +
                    '   </td>' +
                    '</tr>'
    

    $('#listing_tbody').append(newRow);
}
