FactoryGirl.define do
  factory :activity do
    source "github"
    time Time.now
    action "commit"
    description "New commit"
    properties {
      {:branch => 'master'}
    }
  end
end
