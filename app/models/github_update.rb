class GithubUpdate
  include Virtus

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :repository, :commits, :project
  attribute :ref, String
  attribute :before, String
  attribute :after, String
  attirbute :branch, String
  
  def save
  end

  private

  def commit_params
  end

  def find_project
  end

  def find_branch
  end

end