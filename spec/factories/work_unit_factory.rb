Factory.define :work_unit do |work_unit|
  work_unit.start_time Time.now - 20.hours
  work_unit.stop_time Time.now
  work_unit.hours 9.00
  work_unit.notes "value for notes"
  work_unit.association :user
  work_unit.association :project
  work_unit.billable  true
end

Factory.define :in_progress_work_unit, :parent => :work_unit do |wu|
  wu.stop_time nil
  wu.hours nil
end
