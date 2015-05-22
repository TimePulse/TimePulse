class GithubCommit < ActivityBuilder

  attribute :id, String
  attribute :message, String
  attribute :timestamp, DateTime
  attribute :branch, String
  attribute :project_id, Integer
  attr_accessor :author

  def build
    # double check to make sure a commit with this sha is not already in DB
    @activity = Activity.where('properties @> hstore(:key, :value)',
                                key: 'id', value: id
    ).first
    super
  end

  private

  def activity_params
    super.merge({
      :source => "github",
      :action => "commit",
      :description => message,
      :time => timestamp,
      :properties => {
        id: id,
        branch: branch
      }
    })
  end

  def find_project
    if (project_id)
      @project = Project.find(project_id)
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
