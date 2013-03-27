

class InvoiceReport
  attr_accessor :invoice, :work_units

  def initialize(invoice)
    self.invoice = invoice
    self.work_units = invoice.work_units
  end

  def users
    work_units.all.map{|wu| wu.user}.uniq
  end

  def days
    work_units.all.map{ |wu| wu.stop_time.to_date }.uniq.sort
  end


end
