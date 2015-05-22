class Repository < ActiveRecord::Base

  belongs_to :project
  # validates_presence_of :project_id
  # validates_presence_of :url

end
