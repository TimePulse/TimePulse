Ninja.behavior({
  // sets conditional for where the element will be
  'body.users #generate_api_token': {
    click: function() {
      $('#api_token_modal').foundation('reveal', 'open');
    }
  }

});