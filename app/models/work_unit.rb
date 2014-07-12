# == Schema Information
#
# Table name: work_units
#
#  id         :integer(4)      not null, primary key
#  project_id :integer(4)
#  user_id    :integer(4)
#  start_time :datetime
#  stop_time  :datetime
#  hours      :decimal(8, 2)
#  notes      :string(255)
#  invoice_id :integer(4)
#  bill_id    :integer(4)
#  created_at :datetime
#  updated_at :datetime
#  billable   :boolean(1)      default(TRUE)
#

class WorkUnit < ActiveRecord::Base

  scope :in_progress, -> { where("hours IS NULL and start_time IS NOT NULL") }
  scope :completed, -> { where("hours IS NOT NULL") }
  scope :recent, lambda { order(stop_time: :desc).limit(8) }

  scope :billable, -> { where(:billable => true) }

  scope :unbilled, -> { where( :bill_id => nil, :billable => true) }
  scope :uninvoiced, -> { where( :invoice_id => nil, :billable => true) }
  scope :billed, -> { where("bill_id IS NOT NULL") }
  scope :invoiced, -> { where("invoice_id IS NOT NULL") }

  scope :unbillable, -> { where(:billable => false) }

  scope :user_work_units, ->(user) {
    where("user_id = ?", user.id)
  }

  scope :most_recent, ->(number) {
    order(start_time: :desc).limit(number)
  }

  scope :for_client, lambda { |client|
    projects = client.projects.map{ |p| p.self_and_descendants.map{|q| q.id } }.flatten.uniq
    where(:project_id => projects)
  }

  scope :for_project, lambda { |project|
    projects = project.self_and_descendants.map{ |q| q.id }.flatten.uniq
    where(:project_id => projects)
  }

  scope :today, -> { where("stop_time > ? ", Time.zone.now.to_date) }
  scope :this_week, -> { where("stop_time > ? ", Time.zone.now.beginning_of_week.to_date) }
  scope :in_last, ->(num_days) {
    where("stop_time > ? ", (Time.zone.now - num_days.days).to_date)
  }

  attr_accessor :time_zone
  belongs_to :user
  belongs_to :project
  belongs_to :invoice
  belongs_to :bill

  validates_presence_of :project_id
  validates_presence_of :user_id
  validates_presence_of :start_time

  # can't have a stop time without hours also specified
  validates_presence_of :hours, :if => Proc.new{ |wu| wu.stop_time }

  # can't have negative hours
  validates_numericality_of :hours, :greater_than_or_equal_to => 0, :if => Proc.new{ |wu| wu.hours }

  # A work unit is in progress if it has been started
  # but does not have hours yet.
  def in_progress?
    start_time && !hours
  end

  def completed?
    !in_progress?
  end

  def invoiced?
    !invoice_id.nil?
  end

  def billed?
    !bill_id.nil?
  end

  def annotated?
    hours < SHORT_WORK_THRESHOLD or not notes.blank?
  end

  # TODO: spec this method
  def clock_out!
    # debugger
    self.stop_time ||= Time.zone.now
    self.hours ||= WorkUnit.decimal_hours_between(self.start_time, self.stop_time)
    self.truncate_hours!
    save!
  end

  # def project_id=(value)
  #   self.write_attribute(:project_id, value)
  #   self.billable= project.billable if project
  # end

  # TODO: spec this method
  # compute the number of hours (as a decimal) between
  # two times
  HOUR_DECIMAL = BigDecimal.new("3600.00")
  def self.decimal_hours_between(start, stop)
    start_decimal = BigDecimal.new(start.to_i.to_s)
    stop_decimal = BigDecimal.new(stop.to_i.to_s)
    diff = stop_decimal - start_decimal
    (diff / HOUR_DECIMAL).round(2)
  end

  def truncate_hours!
    unless self.hours.nil? || self.start_time.nil? || self.stop_time.nil?
      self.hours = [self.hours, WorkUnit.decimal_hours_between(self.start_time, self.stop_time)].min
    end
  end

  #TODO: spec this method
  def rate
    self.user.rate_for(self.project)
  end

  validate :no_double_clocking
  validate :hours_within_time_range
  validate :not_in_the_future
  validate :has_stop_time_if_completed
  after_validation :set_defaults, :on => :create

  private

  def no_double_clocking
    if in_progress? && user.clocked_in? && user.current_work_unit != self
      errors.add :base, "You may not clock in twice at the same time."
    end
  end

  def hours_within_time_range
    if stop_time && start_time && hours
      if hours > WorkUnit.decimal_hours_between(start_time, stop_time)
        errors.add :base, "Hours must not be greater than the difference between start and stop times."
      end
    end
  end

  def has_stop_time_if_completed
    errors.add(:base, "Completed work units must have a stop time") if (hours && !stop_time)
  end

  def not_in_the_future
    errors.add(:stop_time, "must not be in the future") if stop_time && stop_time > Time.zone.now
    errors.add(:start_time, "must not be in the future") if start_time && start_time > Time.zone.now
  end

  def set_defaults
    self.billable = project.billable if project && self.billable.nil?
  end
end
