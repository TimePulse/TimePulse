Factory.define :bill do |bill|
  bill.due_on   Date.today + 30.days
  bill.paid_on  nil
  bill.notes    "Comments on bill"
  bill.association :user
end