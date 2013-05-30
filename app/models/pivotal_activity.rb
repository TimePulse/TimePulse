class PivotalActivity < ActivityBuilder

  attr_accessor :stories
  attribute :id, Integer
  attribute :version, Integer
  attribute :event_type, String
  attribute :occurred_at, DateTime
  attribute :author, String
  attribute :project_id, Integer
  attribute :description, String

  private

  def timestamp
    occurred_at
  end
  
  def activity_params
    super.merge({
      :source => "pivotal",
      :action => event_type,
      :description => description,
      :time => occurred_at,
      :reference_1 => stories[0]["id"],
      :reference_2 => stories[0]["current_state"],
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

end