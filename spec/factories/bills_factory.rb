FactoryGirl.define do
  factory :bill do
    due_on   Date.today + 30.days
    paid_on  nil
    notes    "Comments on bill"
    association :user
  end
end
