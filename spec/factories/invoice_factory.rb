Factory.define :invoice do |invoice|
  invoice.due_on Date.today + 15.days
  invoice.paid_on nil
  invoice.notes "value for notes"
  invoice.reference_number "value for reference_number"
  invoice.association :client
end