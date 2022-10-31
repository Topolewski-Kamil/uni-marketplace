$('.listings.search').ready(function(){
    let select_2_items = ["#payment-options-select", "#delivery-options-select", "#condition-options-select", "#location-options-select"]
    select_2_items.forEach(element => $(element).select2())

    if (!$("#show-advanced-search").hasClass("show")){
        $("#advanced_search_form").show()
    }

});