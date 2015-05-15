function showHours(scope) {
  $('div.total').hide();
  $('div.billable').hide();
  $('div.unbillable').hide();
  $('div.' + scope).show();
}
function showGraph(scope) {
  $('#total-graph-container').hide();
  $('#billable-graph-container').hide();
  $('#unbillable-graph-container').hide();
  $('#' + scope + '-graph-container').show();
}
function formatDate(date) {
  var monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
  return monthNames[date.getMonth()] + ' ' + date.getDate() + ' ' + date.getFullYear().toString().split('')[2] + date.getFullYear().toString().split('')[3];
}

Ninja.behavior({
  '#total-user-hours-btn': {
    click: function() {
      showHours('total');
      $('#total-user-hours-btn').css("background-color","#165D75");
      $('#all-user-hours-btn').css("background-color","#2BA6CB");
      $('#billable-user-hours-btn').css("background-color","#2BA6CB");
      $('#unbillable-user-hours-btn').css("background-color","#2BA6CB");
      showGraph('total');
    }
  },
  '#billable-user-hours-btn': {
    click: function() {
      showHours('billable');
      $('#billable-user-hours-btn').css("background-color","#165D75");
      $('#all-user-hours-btn').css("background-color","#2BA6CB");
      $('#total-user-hours-btn').css("background-color","#2BA6CB");
      $('#unbillable-user-hours-btn').css("background-color","#2BA6CB");
      showGraph('billable');
    }
  },
  '#unbillable-user-hours-btn': {
    click: function() {
      showHours('unbillable');
      $('#unbillable-user-hours-btn').css("background-color","#165D75");
      $('#all-user-hours-btn').css("background-color","#2BA6CB");
      $('#billable-user-hours-btn').css("background-color","#2BA6CB");
      $('#total-user-hours-btn').css("background-color","#2BA6CB");
      showGraph('unbillable');
    }
  },
  '#all-user-hours-btn': {
    click: function() {
      $('div.total').show();
      $('div.billable').show();
      $('div.unbillable').show();
      $('#all-user-hours-btn').css("background-color","#165D75");
      $('#unbillable-user-hours-btn').css("background-color","#2BA6CB");
      $('#billable-user-hours-btn').css("background-color","#2BA6CB");
      $('#total-user-hours-btn').css("background-color","#2BA6CB");
      showGraph('total');
    }
  }
});