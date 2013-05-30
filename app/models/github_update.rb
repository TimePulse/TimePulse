class GithubUpdate
  include Virtus

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :repository, :commits, :project
  attribute :ref, String
  attribute :before, String
  attribute :after, String
  attribute :branch, String
  
  def save

    find_project
    find_branch
    if project
      commits.each do |commit|
        saved_commit = GithubCommit.new(commit_params(commit))
        if !saved_commit.valid?
          return false
        end
        saved_commits << saved_commit
      end
      saved_commits.each do |saved_commit|
        saved_commit.save
      end
      return true
    else
      return false
    end
  end

  private

  def saved_commits
    @saved_commits ||= []
  end

  def commit_params(commit)
    params = commit
    params[:project_id] = project.id
    params[:branch] = branch
    params
  end

  def find_project
    url = repository[:url]
    @project = Project.where(:github_url => url).first

    #catch same URL with alternate or protocol
    unless @project
      protocol, location = url.split("://")
      @project = Project.where(:github_url => location).first
    end

    unless @project
      if (protocol == "https")
        new_url = "http://" + location
      else
        new_url = "https://" + location
      end
      @project = Project.where(:github_url => new_url).first
    end
  end

  def find_branch
    @branch = ref.gsub("refs/heads/", "")
  end

end