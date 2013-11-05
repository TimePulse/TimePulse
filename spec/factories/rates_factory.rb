FactoryGirl.define  do
  factory :rate do
    name "amount for name"
    amount 100
    association :project
  end
end

FactoryGirl.define  do
  factory :rates_user do
    association :rate
    association :user
  end
end
