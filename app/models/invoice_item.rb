class InvoiceItem < ActiveRecord::Base
  belongs_to :invoices

  attr_accessible :amount, :hours, :name
end
