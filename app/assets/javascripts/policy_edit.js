$(".policies.show").ready(() => {
    const alrt = $('#submit_alert');
    alrt.hide()

    $('#markdown_form').on('ajax:success', () => {
        $('.alert').alert();
        alrt.show()
    }).on('ajax:error', () => {
        alert("Failed to update policy.")
    });

    const submit_btn = $('#submit_button');
    submit_btn.click(function(){
        document.body.scrollTop = 0;
        document.documentElement.scrollTop = 0;
    })
});


function markdown_preview()
{
    let markdown_raw = $('#markdown_raw').val();

    $.ajax({
        url: "/policies/parse",
        dataType:"json",
        type: "get",
        data: {raw:markdown_raw},
        success: function(data) {
            console.log(data);
            let markdown_parsed = $('#markdown_parsed');
            markdown_parsed.html(data)
        },
        error: function(data) {console.log('Could not get parsed markdown')}
    })
}