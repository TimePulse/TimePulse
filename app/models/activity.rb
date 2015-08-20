class Activity < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  belongs_to :work_unit

  validates_presence_of :project, :source

  scope :recent, lambda { order(:time => :desc).limit(8) }

  scope :git_commits, lambda { where(:source => "github") }

  scope :pivotal_updates, lambda { where(:source => "pivotal") }

  scope :story_changes, lambda { where("defined(properties, ?)", "current_state") }

  scope :orphan, lambda { where(:work_unit_id => nil) }

  #TODO Fix these - it may involve using STI so we have actual classes for each
  #activity type
  def story_id
    if self.properties && self.properties.include?('story_id') then
      self.properties['story_id'].to_i
    end
  end
  def current_state
    self.properties['current_state']
  end
  def branch
    self.properties['branch']
  end

end
