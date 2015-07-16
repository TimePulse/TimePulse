class GithubPull < GithubCommitSaver

  attr_accessor :project_id

  def project
    @project ||= Project.find(project_id).repository_source
  end

  def commits
    if @commits.nil?
      @commits = []
      project.repositories.each do | repository |
        if github_api_interface(repository.url)
          @commits += github_api_interface(repository.url).repos.commits.all
        end
      end
    end
    return @commits
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

  def github_api_interface(url)
    if defined?(::API_KEYS)
      @github_api_interface ||= begin
        url_parts = url.split("/")
        repo = url_parts.pop
        user = url_parts.pop
        Github.new(:oauth_token => ::API_KEYS[:github],
          :auto_pagination => true,
          :user => user,
          :repo => repo)
      end
    else
      nil
    end
  end

end
