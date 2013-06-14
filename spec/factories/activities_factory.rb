Factory.define :activity do |activity|
  activity.source "Github"
  activity.time Time.now
  activity.action "commit"
  activity.description "New Commit"
  activity.reference_1 "safdsfdas334"
  activity.reference_2 "afdfdsfdsafds"
end