class UserPreferences < ActiveRecord::Base
  belongs_to :user

  attr_accessible :recent_projects_count

  before_save :default_values

  def default_values
    self.recent_projects_count ||= 5
  end
end