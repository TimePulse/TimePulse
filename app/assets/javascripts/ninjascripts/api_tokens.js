Ninja.behavior({
  // sets conditional for where the element will be
  'body.users #generate_api_token': {
    click: function() {
      $.ajax({method: "PUT",
              url: "/user_api_tokens.json",
              headers:{'x-csrf-token': $('meta[name="csrf-token"]').attr("content")},
              xhrfields:{"withCredentials": true},
              success: function(data){
                $('#api_token_modal').foundation('reveal', 'open');
                $('#token').html(data["token"]);
              }
      });
    }
  }
});