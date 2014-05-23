class UserPreferences < ActiveRecord::Base

  belongs_to :user

  before_save :default_values

  def default_values
    self.recent_projects_count ||= 5
  end
end
