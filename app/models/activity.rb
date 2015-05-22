class Activity < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  belongs_to :work_unit

  #TODO Need to replace this with strong params, but anticipating this model to be rewritten with the new archtitecture
  # attr_accessible :description, :action, :reference_1, :reference_2, :reference_3, :source, :time
  validates_presence_of :project, :source

  scope :recent, lambda { order(:time => :desc).limit(8) }

  scope :git_commits, lambda { where(:source => "github") }

  scope :pivotal_updates, lambda { where(:source => "pivotal") }

  scope :story_changes, lambda { where("defined(properties, ?)", "current_state") }

  #TODO Fix these - it may involve using STI so we have actual classes for each
  #activity type
  def story_id
    self.properties['story_id']
  end
  def current_state
    self.properties['current_state']
  end
  def branch
    self.properties['branch']
  end

end
