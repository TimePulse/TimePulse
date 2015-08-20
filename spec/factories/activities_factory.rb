FactoryGirl.define do
  factory :activity do
    source "github"
    time Time.now
    project
    user
    work_unit_id nil
    action "commit"
    description "New commit"
    properties {
      {:branch => 'master'}
    }
  end
end
