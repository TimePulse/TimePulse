FactoryGirl.define do
  factory :activity do
    source "Github"
    time Time.now
    action "commit"
    description "New Commit"
    reference_1 "safdsfdas334"
    reference_2 "afdfdsfdsafds"
  end
end
