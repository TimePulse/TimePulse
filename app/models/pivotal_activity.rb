class PivotalActivity < ActivityBuilder

  attr_accessor :stories
  attribute :id, Integer
  attribute :version, Integer
  attribute :event_type, String
  attribute :occurred_at, DateTime
  attribute :author, String
  attribute :project_id, Integer
  attribute :description, String

  def build
    # double check to make sure a commit with this sha is not already in DB
    @activity = Activity.where('properties @> hstore(:key, :value)',
                                           key: 'id', value: id.to_s
    ).first
    super
  end

  private

  def timestamp
    occurred_at
  end

  def activity_params
    if stories.present?
      story = stories[0].symbolize_keys!
      story_id = story[:id]
      current_state = story[:current_state]
    end
    super.merge({
      :source => "pivotal",
      :action => event_type,
      :description => description,
      :time => occurred_at,
      :properties => {
        story_id: story_id,
        current_state: current_state,
        id: id.to_s
      }
    })
  end

  def find_project
    if (project_id)
      @project = Project.where(:pivotal_id => project_id).first
    end
  end

  def find_user
    if author
      @user = User.find_by_pivotal_name(author)
    end
    if !user and author
      @user = User.find_by_name(author)
    end
  end
  
  def find_work_unit
    if @user && @project
      WorkUnit.where(user: @user, project: @project).each do |work_unit|
        return @work_unit = work_unit if work_unit.includes_time(@occurred_at)
      end
    end
  end

end
