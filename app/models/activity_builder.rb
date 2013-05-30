class ActivityBuilder
  include Virtus

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  
  attr_accessor :user, :project, :activity

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
    }
  end

end
