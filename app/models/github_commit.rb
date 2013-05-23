class GithubCommit
  include Virtus

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attribute :id, String
  attribute :message, String
  attribute :timestamp, DateTime
  attribute :branch, String

  attr_accessor :user, :project, :work_unit, :activity, :author

  def save
    find_user
    find_work_unit
    @activity = Activity.new(activity_params)
    if @activity.valid?
      @activity.save
      true
    else
      false
    end
  end

  private

  def activity_params
    {
      :source => "github",
      :action => "commit",
      :description => message,
      :time => timestamp,
      :reference_1 => id,
      :reference_2 => branch,
      :user_id => (user ? user.id : nil),
      :project_id => (project ? project.id : nil),
      :work_unit_id => (work_unit ? work_unit.id : nil)
    }
  end

  def find_work_unit
    if user and project
      possible_work_units = user.work_units_for(project)
      min_time = timestamp.advance(:minutes => 15)
      max_time = timestamp.advance(:minutes => -15)
      @work_unit = possible_work_units.where('start_time <= ? and stop_time >= ?', min_time, max_time).first
    end
  end

  def find_user
    if author[:username]
      @user = User.find_by_github_user(author[:username])
    end
    if !user and author[:email]
      @user = User.find_by_email(author[:email])
    end
  end

end
