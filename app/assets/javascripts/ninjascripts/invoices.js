RateTotal.prototype = {
  addHoursWithRate: function(newHours) {
    this.hours += newHours;
    this.totalDollars = this.hours * this.amount;
  }
};
function RateTotal(id, amount) {
  this.id = id;
  this.amount = amount;
  this.count = 0;
  this.hours = 0.0;
  this.totalDollars = 0.0;
}

InvoiceCalculator = {
  selectAll: function() {
    $('.work_unit_checkbox').prop('checked', true);
    this.calculateTotals();
  },
  calculateTotals: function() {
    var rateName, rateAmount;
    var newHours;
    var self = this;
    this.rateTotals = {};
    this.workUnitHours.each(function() {
      if ($(this).find('.work_unit_checkbox').is(':checked')) {
        rateId = $(this).data('rate-id');
        rateName = $(this).data('rate-name');
        rateAmount = $(this).data('rate-amount');
        if (typeof rateName == 'undefined') {
          show_ajax_message('Work Unit has no rate!', 'error');
          return;
        }
        if (!self.rateTotals[rateName]) {
          self.rateTotals[rateName] = new RateTotal(rateId, rateAmount);
        }
        newHours = $(this).find('.hours_count').html() * 1.0;
        self.rateTotals[rateName].addHoursWithRate(newHours);
        self.rateTotals[rateName].count++;
      }
    });
    this.updateDisplay();
  },

  buildRow: function(name, rateTotal) {
    var rowString = "<tr id='rate_";
    rowString += rateTotal.id;
    rowString += "'><td>";
    rowString += name;
    if (rateTotal.amount) {
      rowString += (" (" + (Math.round(rateTotal.amount*100)/100).toFixed(2) +")")
    }
    rowString += "</td><td>";
    rowString += rateTotal.count;
    rowString += "</td><td>";
    rowString += (Math.round(rateTotal.hours*100)/100).toFixed(2);
    rowString += "</td><td>";
    rowString += (Math.round(rateTotal.totalDollars*100)/100).toFixed(2);
    rowString += "</td></tr>";
    return $(rowString);
  },

  updateDisplay: function() {
    var totalsTable = $('#new_invoice #totals tbody');
    totalsTable.find('tr').remove();
    var grandTotal = new RateTotal('total', null);
    for (key in this.rateTotals) {
      this.buildRow(key, this.rateTotals[key]).appendTo(totalsTable);
      grandTotal.count += this.rateTotals[key].count;
      grandTotal.hours += this.rateTotals[key].hours;
      grandTotal.totalDollars += this.rateTotals[key].totalDollars;
    }
    this.buildRow("Totals", grandTotal).appendTo(totalsTable);
  },

  setup: function() {
    this.workUnitHours = $('#new_invoice .work_unit .hours');
  }
};

Binder.bindAll(InvoiceCalculator);

Ninja.behavior({
  'body.invoices': {
    transform: InvoiceCalculator.setup
  },
  'body.invoices .work_unit_checkbox': {
    click: [ InvoiceCalculator.calculateTotals, "andDoDefault"]
  },
  'body.invoices #work_unit_select_all': {
    click: InvoiceCalculator.selectAll
  }
});
