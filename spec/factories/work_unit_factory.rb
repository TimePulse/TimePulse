FactoryGirl.define  do
  factory :work_unit do

    start_time {(Time.now - 20.hours).utc}
    stop_time {(Time.now).utc}
    hours 9.50
    sequence(:notes){ |n| "Work Unit Notes #{n}" }
    association :user
    association :project
    billable  true

    factory :work_unit_with_annotation do
      transient do
        description "Annotation"
      end

      after(:create) do |work_unit, evaluator|
        FactoryGirl.create(:activity,
                   work_unit: work_unit,
                   project: work_unit.project,
                   user: work_unit.user,
                   action: "Annotation",
                   description: evaluator.description)
      end
    end

  end
end

FactoryGirl.define  do
  factory :in_progress_work_unit, :parent => :work_unit do
    stop_time nil
    hours nil
  end
end
