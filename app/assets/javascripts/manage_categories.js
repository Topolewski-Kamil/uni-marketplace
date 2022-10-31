$('.moderator').ready(function() {
    $('#categories_submit_alert').hide();
    $('#categories_delete_alert').hide();

    // hide elements again when modal is closing
    $('#manage_categories').on('hidden.bs.modal', function() {
        $('#categories_submit_alert').hide();
        $('#categories_delete_alert').hide();
        disable_delete_buttons();
    })
    //ajax post request for adding new category
    $("#manage_categories_add_button").click(function() {
        disable_delete_buttons()
        let cat_name =  $('#manage_categories_name_input').val();
        $('#manage_categories_name_input').val('');

        $('#categories_submit_alert').hide();
        $('#categories_delete_alert').hide();

        $.ajax({
            url: "/categories/add_category",
            dataType: "json",
            type: "post",
            data: {name: cat_name},
            success: function(data) {
                $('#categories_submit_alert').show();
                build_row(data)
            }, 
            error: function(data) {alert(data.responseJSON.reason)}
        });
    })
});

function disable_delete_buttons() {
    $('.category_delete_btn').css("display", "none")
}

// for adding new category to the table 
function build_row(data) {
    let newRow =    '<tr>' +
                    '   <td class="align-middle">' +  data.name + '</td>' +
                    '   <td class="align-middle text-right">' + 
                    '       <button class="btn-sm btn-danger category_delete_btn" onclick="delete_category(event)" id="' + data.id + '" data-category= "'+ data.name +'">' +
                    '           <i class="fas fa-minus"></i>' +
                    '       </button>' +
                    '   </td>' +
                    '</tr>';

    
    // insert new row at right position (alphabetically)
    let wasInserted = false;
    // iterate over rows in table, find first row that should come after new row, append new row before it
    $('#manage_categories_tbody').children('tr').each(function(i) {
        let category_name = $(this).first().text().trim()
        let order = category_name.localeCompare(data.name);
        if (order == 1) {
            $(this).before(newRow);
            wasInserted = true
            return false;
        }
    });
    if (!wasInserted)
        $('#manage_categories_tbody').append(newRow);
}


//ajax post request for deleting existing categories
function delete_category(event) {
    $('#categories_submit_alert').hide();
    $('#categories_delete_alert').hide();

    let category_id;
    let category_name
    if ($(event.target).is("button")){
        category_id = event.target.id;
        category_name = event.target.dataset.category;
    }
    else{
        category_id = $(event.target).closest('button').attr('id');
        category_name = $(event.target).closest('button').data("category");
    }
    let msg =   "You are deleting the category '" + category_name + "'\n\n" +
                "Any listing associated with this category, will have its category changed to 'Removed_Category'\n\n" +
                "Press OK to continue."
    var r = confirm(msg)
    if (!r)
        return

    //console.log('Deleting id: ' + category_id)
    $.ajax({
        url: "/categories/delete_category",
        dataType: "json",
        type: "post",
        data: {id: category_id},
        success: function(data) {
            $('#categories_delete_alert').show();
            //console.log('Category deleted');
            //remove the row from the table
            $('#' + data.id).parent().parent().remove();
        },
        error: function(data) {alert('Something went wrong.')}
    });
}


function enable_delete_buttons() {
    $('.category_delete_btn').css("display", "initial")
}