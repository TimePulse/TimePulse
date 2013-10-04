class GithubPull < GithubCommitSaver

  attr_accessor :project_id

  def project
    @project ||= Project.find(project_id)
  end

  def commits
    @commits ||= github_api_interface.repos.commits.all
  end

  protected

  def commit_params(commit)
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

  def github_api_interface
    url_parts = project.github_url.split("/")
    repo = url_parts.pop
    user = url_parts.pop
    Github.new(:oauth_token => ::API_KEYS[:github],
      :auto_pagination => true,
      :user => user,
      :repo => repo)
  end

end
