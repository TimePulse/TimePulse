class InvoiceItem < ActiveRecord::Base
  belongs_to :invoice

  #TODO Need to replace this with strong params, but anticipating this model to be rewritten with the new archtitecture
  # attr_accessible :amount, :hours, :total, :name
end
