class ActivityBuilder
  include Virtus.model

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :user, :project, :activity, :work_unit

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

  def persisted?
    activity.persisted?
  end

  protected

  def build
    unless activity
      find_project
      find_user
      find_work_unit
      @activity = Activity.new(activity_params)
      @activity.user_id = @user ? @user.id : nil
      @activity.project_id = @project ? @project.id : nil
      @activity.work_unit_id = @work_unit ? @work_unit.id : nil
    end
    if activity.valid?
      true
    else
      false
    end
  end

  def activity_params
    {
    }
  end

end
