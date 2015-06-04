class OrphanActivityAssociator
  def initialize(earliest_time)
    @time_from = earliest_time
  end
  attr_reader :time_from

  def run
    Activity.orphan.where("time > ?", time_from).each do |activity|
      work_units = WorkUnit.where(:user_id => activity.user_id,
                                  :project_id => activity.project_id).where(
                                    "start_time < ? AND ? < stop_time",
                                    activity.time + 15.minutes, activity.time - 15.minutes)
      activity.work_unit = work_units.first
      activity.save!
    end
  end
end
