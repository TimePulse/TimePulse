class GithubCommitSaver
  include Virtus.model

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  def save
    if project
      commits.each do |commit|
        saved_commit = GithubCommit.new(commit_params(commit))
        if !saved_commit.valid?
          return false
        end
        saved_commits << saved_commit
      end
      saved_commits.each do |saved_commit|
        if !saved_commit.persisted?
          saved_commit.save
        end
      end
      return true
    else
      return false
    end
  end

  protected

  def saved_commits
    @saved_commits ||= []
  end

end
