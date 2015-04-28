function showHours(category) {
	$('span.total').hide();
	$('span.billable').hide();
	$('span.unbillable').hide();
	$('span.' + category).show();
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