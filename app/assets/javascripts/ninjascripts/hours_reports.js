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
	}
});