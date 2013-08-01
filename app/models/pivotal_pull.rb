class PivotalPull

  attr_accessor :project_id

  def initialize(params)
    @project_id = params[:project_id]
  end

  def save
    if project
      activities.each do |activity|
        saved_activity = PivotalActivity.new(activity_params(activity))
        if !saved_activity.valid?
          return false
        end
        saved_activities << saved_activity
      end
      saved_activities.each do |saved_activity|
        if !saved_activity.persisted?
          saved_activity.save
        end
      end
      return true
    else
      return false
    end
  end

  def project
    @project ||= Project.find(project_id)
  end

  def activities
    @activities ||= pivotal_api_interface.activities.all(:auto_page => true)
  end

  protected

  def activity_params(activity)
    {
    :id => activity.id,
    :version => activity.version,
    :event_type => activity.event_type,
    :occurred_at => activity.occurred_at,
    :author => activity.author.person.name,
    :project_id => activity.project_id,
    :description => activity.description,
    :stories => activity.stories.map{ |story| {"id" => story.id, "current_state" => story.current_state } }
    }
  end

  def saved_activities
    @saved_activities ||= []
  end

  protected

  def pivotal_api_interface
    PivotalTracker::Client.api_version = 4
    PivotalTracker::Client.token = ::API_KEYS[:pivotal]
    PivotalTracker::Project.find(@project.pivotal_id)
  end

end
