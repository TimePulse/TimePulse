

class InvoiceReport
  attr_accessor :invoice

  def initialize(invoice)
    self.invoice = invoice
  end

  def users
    invoice.work_units.all.map{|wu| wu.user}.uniq
    #[]
  end
end
