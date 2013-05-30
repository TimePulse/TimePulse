class Activity < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  belongs_to :work_unit
  attr_accessible :description, :action, :reference_1, :reference_2, :source, :time, :user_id, :project_id, :work_unit_id

  validates_presence_of :project, :source

  scope :recent, :limit => 8, :order => "time DESC"
  scope :git_commits, where(:source => "github")
  scope :pivotal_updates, where(:source => "pivotal")
end

