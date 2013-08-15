# == Schema Information
#
# Table name: users
#
#  id                  :integer(4)      not null, primary key
#  login               :string(255)     not null
#  email               :string(255)     not null
#  current_project_id  :integer(4)
#  name                :string(255)     not null
#  crypted_password    :string(255)     not null
#  password_salt       :string(255)     not null
#  persistence_token   :string(255)     not null
#  single_access_token :string(255)     not null
#  perishable_token    :string(255)     not null
#  login_count         :integer(4)      default(0), not null
#  failed_login_count  :integer(4)      default(0), not null
#  last_request_at     :datetime
#  current_login_at    :datetime
#  last_login_at       :datetime
#  current_login_ip    :string(255)
#  last_login_ip       :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#

class User < ActiveRecord::Base

  devise :database_authenticatable, :registerable,
       :recoverable, :rememberable, :trackable, :validatable, :confirmable

  belongs_to :current_project, :class_name => "Project"
  has_many :work_units
  has_many :bills
  has_many :activities
  has_many :rates_users
  has_many :rates, :through => :rates_users

  validates_presence_of :name, :email

  scope :inactive, :conditions => { :inactive => true  }
  scope :active,   :conditions => { :inactive => false }

  attr_accessible :login, :name, :email, :current_project_id, :password, :password_confirmation, :github_user, :pivotal_name

  has_and_belongs_to_many :groups

  def reset_current_work_unit
    @cwu = nil
  end

  def current_work_unit
    @cwu ||= work_units.in_progress.first
  end

  def clocked_in?
    reset_current_work_unit
    !current_work_unit.nil?
  end

  def recent_work_units
    work_units.completed.recent.includes(:project => :client)
  end

  def recent_commits
    activities.git_commits.recent.includes(:project => :client)
  end

  def recent_pivotal_updates
    activities.pivotal_updates.recent.includes(:project => :client)
  end

  def time_on_project(project)
    work_units_for(project).sum(:hours)
  end

  def unbilled_time_on_project(project)
    work_units_for(project).unbilled.sum(:hours)
  end

  def unbillable_time_on_project(project)
    work_units_for(project).unbillable.sum(:hours)
  end

  def completed_work_units_for(project)
    work_units_for(project).completed
  end

  def git_commits_for(project)
    source = project.github_url_source
    source ||= project
    activity_for(source).git_commits
  end

  def pivotal_updates_for(project)
    source = project.pivotal_id_source
    source ||= project
    activity_for(source).pivotal_updates
  end

  def current_project_hours_report
    @cphr ||= hours_report_on(current_project)
  end

  def hours_report_on(project)
    HoursReport.new(project, self)
  end

  def admin?
    groups.include?(Group.admin_group)
  end

  def activity_for(project)
    ProjectActivityQuery.new(activities).find_for_project(project)
  end

  def work_units_for(project)
    ProjectWorkQuery.new(work_units).find_for_project(project)
  end

  def rate_for(project)
    project = project.parent unless project.is_base_project?
    (project.rates & rates).last
  end

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(login) = :value OR lower(email) = :value", 
                               { :value => login.downcase}]).first
    else
      where(conditions).first
    end
  end
end

