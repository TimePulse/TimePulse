# == Schema Information
#
# Table name: projects
#
#  id          :integer(4)      not null, primary key
#  parent_id   :integer(4)
#  lft         :integer(4)
#  rgt         :integer(4)
#  client_id   :integer(4)
#  name        :string(255)
#  account     :string(255)
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#

FactoryGirl.define  do
  factory :project  do |c|
    sequence(:name) { |n|  "Foo Project #{n}" }
    association :client
    clockable true
    github_url ""
    pivotal_id 123
    parent_id { Project.root.id }
    trait :with_rate do
      after(:create) { |p| FactoryGirl.create(:rate, :project => p)  }
    end
  end


end

FactoryGirl.define  do
  factory :task, :parent => :project do |c|
    name "Clientactics Task"
    clockable true
    parent { |parent| parent.association(:project) }
  end
end
