function showHours(category) {
	$('span.total').hide();
	$('span.billable').hide();
	$('span.unbillable').hide();
	$('span.' + category).show();
}
function formatDate(date) {
	var monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
	return monthNames[date.getMonth()] + ' ' + date.getDate() + ' ' + date.getFullYear().toString().split('')[2] + date.getFullYear().toString().split('')[3];
}

Ninja.behavior({
	'#total-user-hours-btn': {
		click: function() {
			showHours('total');
		}
	},
	'#billable-user-hours-btn': {
		click: function() {
			showHours('billable');
		}
	},
	'#unbillable-user-hours-btn': {
		click: function() {
			showHours('unbillable');
		}
	},
	'#all-user-hours-btn': {
		click: function() {
			$('span.total').show();
			$('span.billable').show();
			$('span.unbillable').show();
		}
	},
	'#new-dates-btn': {
		click: function() {
			var end_date = $('#datepicker').datepicker('getDate');
			$('h2#sunday_5').html('Week ending ' + formatDate(end_date));
			$('h2#sunday_4').html('Week ending ' + formatDate(new Date(end_date.setDate(end_date.getDate() - 7))));
			$('h2#sunday_3').html('Week ending ' + formatDate(new Date(end_date.setDate(end_date.getDate() - 7))));
			$('h2#sunday_2').html('Week ending ' + formatDate(new Date(end_date.setDate(end_date.getDate() - 7))));
			$('h2#sunday_1').html('Week ending ' + formatDate(new Date(end_date.setDate(end_date.getDate() - 7))));
			$('h2#sunday_0').html('Week ending ' + formatDate(new Date(end_date.setDate(end_date.getDate() - 7))));
		}
	}
});