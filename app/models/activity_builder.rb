class ActivityBuilder
  include Virtus

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  
  attr_accessor :user, :project, :work_unit, :activity

  def valid?
    build
  end

  def save
    if valid?
      activity.save
      true
    else
      false
    end
  end

  protected

  def build
    unless activity
      find_project
      find_user
      find_work_unit
      @activity = Activity.new(activity_params)
    end
    if activity.valid?
      true
    else
      false
    end
  end

  def activity_params
    {
      :user_id => (user ? user.id : nil),
      :project_id => (project ? project.id : nil),
      :work_unit_id => (work_unit ? work_unit.id : nil)
    }
  end

  def find_work_unit
    if user and project
      possible_work_units = user.work_units_for(project)
      find_work_unit_in_time_range(possible_work_units)
      if work_unit and work_unit.project != project
        @project = work_unit.project
      end
    end
  end

  def find_work_unit_in_time_range(possible_work_units)

    # search for a completed work unit where timestamp is directly in time range first
    @work_unit = possible_work_units.where('start_time <= ? and stop_time >= ?', timestamp, timestamp).first

    # search for an in progress work unit next
    unless @work_unit
      @work_unit = possible_work_units.in_progress.where('start_time <= ?', timestamp).first
    end

    # search for a completed work unit where timestamp is proximal to work unit next
    unless @work_unit
      min_time = timestamp.advance(:minutes => 15)
      max_time = timestamp.advance(:minutes => -15)
      @work_unit = possible_work_units.where('start_time <= ? and stop_time >= ?', min_time, max_time).first
    end

  end
end
