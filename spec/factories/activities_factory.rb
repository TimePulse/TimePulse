FactoryGirl.define do
  factory :activity do
    source "github"
    time Time.now
    project_id 1
    action "commit"
    description "New commit"
    properties {
      {:id => '12345',
      :branch => 'master'}
    }
  end
end
