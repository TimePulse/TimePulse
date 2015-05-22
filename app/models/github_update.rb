class GithubUpdate < GithubCommitSaver

  attr_accessor :repository, :commits
  attribute :ref, String
  attribute :before, String
  attribute :after, String

  protected

  def commit_params(commit)
    params = commit
    params[:project_id] = project.id
    params[:branch] = branch
    params
  end

  def project

    unless @project
      url = repository[:url]
      id = Repository.where(url: url).first.project_id
      @project = Project.find(id)
    end

    #catch same URL with alternate or protocol
    unless @project
      protocol, location = url.split("://")
      id = Repository.where(url: location).first.project_id
      @project = Project.find(id)
      # @project = Project.where(:github_url => location).first
    end

    unless @project
      if (protocol == "https")
        new_url = "http://" + location
      else
        new_url = "https://" + location
      end
      id = Repository.where(url: new_url).first.project_id
      @project = Project.find(id)
      # @project = Project.where(:github_url => new_url).first
    end

    @project

  end

  def branch
    @branch ||= ref.gsub("refs/heads/", "")
  end

end