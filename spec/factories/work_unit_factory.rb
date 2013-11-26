FactoryGirl.define  do
  factory :work_unit do
    start_time (Time.now - 20.hours).utc
    stop_time (Time.now).utc
    hours 9.50
    sequence(:notes){ |n| "Work Unit Notes #{n}" }
    association :user
    association :project
    billable  true
  end
end

FactoryGirl.define  do
  factory :in_progress_work_unit, :parent => :work_unit do
    stop_time nil
    hours nil
  end
end
