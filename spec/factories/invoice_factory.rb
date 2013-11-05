FactoryGirl.define  do
  factory :invoice do
    due_on Date.today + 15.days
    paid_on nil
    notes "value for notes"
    reference_number "value for reference_number"
    association :client
  end
end
