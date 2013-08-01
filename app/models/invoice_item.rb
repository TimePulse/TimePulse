class InvoiceItem < ActiveRecord::Base
  belongs_to :invoice

  attr_accessible :amount, :hours, :total, :name
end
