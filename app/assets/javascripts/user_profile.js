function ban_user() {
  let user_id = $('#profile_container').attr('data-arg-id');

  $.ajax({
    url: '/users/ban',
    dataType: 'json',
    type: 'post',
    data: {id: user_id},
    success: function(data) {
      let btn = $('#ban_button')
      btn.attr("onclick", "unban_user()");
      btn.html('<i class="fa fa-check-circle" aria-hidden="true"></i> Lift Ban');
      btn.removeClass('btn-outline-danger');
      btn.addClass('btn-outline-success');
      alert('User was succesfully banned')
    },
    error: function(data) {alert("Something went wrong.")}
  });
}

function unban_user() {
  let user_id = $('#profile_container').attr('data-arg-id');

  $.ajax({
    url: '/users/unban',
    dataType: 'json',
    type: 'post',
    data: {id: user_id},
    success: function(data) {
      let btn = $('#ban_button')
      btn.attr("onclick", "ban_user()");
      btn.html('<i class="fa fa-ban" aria-hidden="true"></i> Ban User');
      btn.removeClass('btn-outline-success');
      btn.addClass('btn-outline-danger');
      alert('User was succesfully unbanned')
    },
    error: function(data) {alert("Something went wrong.")}
  });
}