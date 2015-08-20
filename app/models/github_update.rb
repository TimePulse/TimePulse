class GithubUpdate < GithubCommitSaver

  attr_accessor :repository, :commits
  attribute :ref, String
  attribute :before, String
  attribute :after, String

  protected

  def commit_params(commit, project)
    params = commit
    params[:project_id] = project.id
    params[:branch] = branch
    params
  end

  def projects
    unless @projects
      @projects = []
      url = repository[:url]
      Repository.where(url: url).each do |repo|
        @projects << repo.project
      end

      #catch same URL with alternate or protocol
      protocol, location = url.split("://")
      Repository.where(url: location).each do |repo|
        @projects << repo.project
      end

      if (protocol == "https")
        new_url = "http://" + location
      else
        new_url = "https://" + location
      end

      Repository.where(url: new_url).each do |repo|
        @projects << repo.project
      end
      if @projects.blank?
        Rails.logger.warn "No match for Github webhook with url #{url}"
      end
    end

    @projects

  end

  def branch
    @branch ||= ref.gsub("refs/heads/", "")
  end

end