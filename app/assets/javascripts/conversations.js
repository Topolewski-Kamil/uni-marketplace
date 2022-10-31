$(".conversations.show").ready(function() {
  if ($("#chat-box") != undefined){
    $("#chat-box").scrollTop($("#chat-box").prop('scrollHeight'));
  }
  if ($("#chat-box") != undefined){
    $("#conversations-send-form").submit(function(){
      //$("#conversations-message-field").val("");
    })
  }
});