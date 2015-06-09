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
function toggleCheckboxes() {
  var checkboxes = $(':checkbox');
  checkboxes.prop('checked', !checkboxes.prop('checked'));
}

Ninja.behavior({
  '#selectAll': {
    click: function() {
      toggleCheckboxes();
    }
  },
  '#total-user-hours-btn': {
    click: function() {
      showHours('total');
      $('.selected-btn').removeClass('selected-btn');
      $('#total-user-hours-btn').addClass('selected-btn');
      showGraph('total');
    }
  },
  '#billable-user-hours-btn': {
    click: function() {
      showHours('billable');
      $('.selected-btn').removeClass('selected-btn');
      $('#billable-user-hours-btn').addClass('selected-btn');
      showGraph('billable');
    }
  },
  '#unbillable-user-hours-btn': {
    click: function() {
      showHours('unbillable');
      $('.selected-btn').removeClass('selected-btn');
      $('#unbillable-user-hours-btn').addClass('selected-btn');
      showGraph('unbillable');
    }
  },
  '#all-user-hours-btn': {
    click: function() {
      $('div.total').show();
      $('div.billable').show();
      $('div.unbillable').show();
      $('.selected-btn').removeClass('selected-btn');
      $('#all-user-hours-btn').addClass('selected-btn');
      showGraph('total');
    }
  }
});
