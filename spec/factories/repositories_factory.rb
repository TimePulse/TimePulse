FactoryGirl.define  do

  factory :repository do
    association :project
    url 'github.com/new_project'
  end

end