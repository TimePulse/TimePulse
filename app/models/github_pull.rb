class GithubPull < GithubCommitSaver

  attr_accessor :project_id

  # In GithubPull, there will always be either one or no projects.
  # The method "projects" in this model will always be a single object.
  def projects
    unless @projects
      if Project.find(project_id).repositories_source
        @projects = [Project.find(project_id).repositories_source]
      else
        @projects = []
      end
    end
    return @projects
  end

  def commits
    if @commits.nil?
      @commits = []
      projects.first.repositories.each do | repository |
        if github_api_interface(repository.url)
          @commits += @github_api_interface.repos.commits.all
        end
      end
    end
    return @commits
  end

  protected

  def commit_params(commit, project)
    {
      :id => commit.sha,
      :message => commit.commit.message,
      :timestamp => commit.commit.author.date,
      :branch => nil,
      :project_id => project.id,
      :author => {
        :username => (commit.author ? commit.author.login : nil),
        :email => commit.commit.author.email
      }
    }
  end

  def github_api_interface(url)
    if Rails.application.secrets.api_keys['github'].present?
      @github_api_interface = begin
        url_parts = url.split("/")
        repo = url_parts.pop
        user = url_parts.pop
        Github.new(:oauth_token => Rails.application.secrets.api_keys['github'],
          :auto_pagination => true,
          :user => user,
          :repo => repo)
      end
    else
      nil
    end
  end

end
