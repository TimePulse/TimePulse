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
      Repository.where(url: url).each do |repo|
        @project = repo.project
      end
    end

    #catch same URL with alternate or protocol
    unless @project
      protocol, location = url.split("://")
      Repository.where(url: location).each do |repo|
        @project = repo.project
      end
    end

    unless @project
      if (protocol == "https")
        new_url = "http://" + location
      else
        new_url = "https://" + location
      end

      Repository.where(url: new_url).each do |repo|
        @project = repo.project
      end
    end
    
    unless @project
      Rails.logger.warn "No match for Github webhook with url #{url}"
    end

    @project

  end

  def branch
    @branch ||= ref.gsub("refs/heads/", "")
  end

end