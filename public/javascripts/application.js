Ninja.behavior({
  '.mizugumo_graceful_form': Ninja.becomesLink
});

$('document').ready( function(){
  startClock();
});

// $.behavior({
//   '#debug':        $.ninja.tools.suppress_change_events(),
//   '#task_elapsed':  $.ninja.tools.suppress_change_events(),
//   '.date_entry': { transform: function(elem){ $(elem).datepicker() }},
//   '.datetime_entry': { transform: function(elem){ $(elem).datetimepicker() }},
//   '#work_unit_select_all': { click: selectAllWorkUnits },
//   '.work_unit_checkbox': { click: [ updateWorkUnitHoursTotal, "default"] },
//
//   '#timeclock form.edit_work_unit':    $.ninja.ajax_submission({
//     busy_element: function(elem){ return $('#timeclock')}
//   }),
//   '#timeclock form.clock_in':          $.ninja.ajax_submission({
//     busy_element: function(elem){ return $('#timeclock')}
//   }),
//     '.project_picker form.clock_in':   $.ninja.make_ajax_link({
//     busy_element: function(elem){ return $('#timeclock')}
//   }),
//   '#project_picker form.edit_project': $.ninja.make_ajax_link({
//     busy_element: function(elem){ return $('#timeclock')}
//   }),
//
//   '#messages .flash': {
//     transform: function(elem) {
//       $(elem).delay(10000).slideUp(600, function(){$(elem).remove()})
//     }
//   },
//   '#timeclock input#work_unit_hours': {
//     click: function(evnt, elem) {
//       $(elem).val(hours_format(task_elapsed))
//     }
//   },
//   '.has_tooltip': {
//     transform: function(elem){
//       $(elem).tooltip({
//         tip: "#tooltip_for_" + $(elem).attr('id'),
//         offset: [ -10, 2 ]
//         })
//         return elem;
//     }
//   }
// });
//
// function selectAllWorkUnits() {
//   $('.work_unit_checkbox').attr('checked', true);
//   updateWorkUnitHoursTotal();
// }
//
// var task_elapsed;
//
// function updateWorkUnitHoursTotal() {
//   var total = 0.0;
//   var count = 0;
//   $('#new_invoice tr.work_unit .hours, #new_bill tr.work_unit .hours').each(function() {
//     if ($(this).siblings('.work_unit_checkbox').attr('checked')) {
//       total += $(this).html() * 1.0;
//       count++;
//     }
//   });
//   $('#work_unit_count').html(count);
//   $('#hours_total').html(Math.round(total*100)/100);
// }
//
function startClock() {
  $('#browsertime').html(now_sec());

  setInterval('updateClock()', 1000);
}

function updateClock() {
  b_page_time = parseInt($('#browsertime').html());
  s_page_time = parseInt($('#servertime').html());
  task_started = parseInt($('#tasktime').html());
  adjust = b_page_time - s_page_time;
  b_now = now_sec();
  s_now = b_now - adjust;
  task_elapsed = s_now - task_started;
  if (task_elapsed >= 0) {
    $('#task_elapsed').html( hhmmss_format(task_elapsed) );
  }
  $('#time_debug').html("<table class='listing'>" +
    debug_row("Browser Time Now:",new Date().toLocaleString()) +
    debug_row("Browser Render:",b_page_time) +
    debug_row("Server Render:",s_page_time) +
    debug_row("Task Started (sec):",task_started) +
    debug_row("Task Started (time):",new Date(task_started*1000).toLocaleString()) +
    debug_row("Adjustment:",adjust) +
    debug_row("Browser Now:",b_now) +
    debug_row("Server Now:",s_now) +
    debug_row("Task Elapsed", task_elapsed)
    + "<table>"
  );
}

function debug_row(label, value) {
 return "<tr><th>" + label + "</th><td>" + value + "</td></tr>";
}

function now_sec() {
 return Math.round(new Date().getTime()/1000);
}

function hours_format(sec) {
 return Math.floor(sec / 36.0) / 100.0;
}

function hhmm_format(sec) {
 return Math.floor(sec/3600) + ":" + zeropad(Math.floor(sec / 60) % 60);
}

function hhmmss_format(sec) {
 return hhmm_format(sec) + ":" + zeropad(sec % 60)
}

function zeropad(field) {
  if (field < 10)
    return "0"+field;
  else
    return field;
}