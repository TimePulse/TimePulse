# == Schema Information
#
# Table name: projects
#
#  id          :integer(4)      not null, primary key
#  parent_id   :integer(4)
#  lft         :integer(4)
#  rgt         :integer(4)
#  client_id   :integer(4)
#  name        :string(255)     not null
#  account     :string(255)
#  description :text
#  clockable   :boolean(1)      default(FALSE), not null
#  created_at  :datetime
#  updated_at  :datetime
#  billable    :boolean(1)      default(TRUE)
#  flat_rate   :boolean(1)      default(FALSE)
#

require 'cascade'

class Project < ActiveRecord::Base

  include Cascade

  acts_as_nested_set
  belongs_to :client
  has_many :work_units
  has_many :activities
  # Rates added to sub-project will override parent project rates completely.
  # Users may see rates disappear from a child when adding rates specifically for a child.
  has_many :rates
  accepts_nested_attributes_for :rates, :allow_destroy => true, :reject_if => lambda { |attr| attr['name'].blank? || attr['amount'].to_i < 1  }

  scope :archived, lambda { where( :archived => true) }
  scope :unarchived, lambda { where( :archived => false) }
  # default_scope :joins => :client

  validates_presence_of :name
  cascades :account, :clockable, :github_url, :pivotal_id

  attr_accessible :name, :account, :description, :clockable, :billable, :flat_rate, :archived, :github_url, :pivotal_id, :rates_attributes

  before_save :no_rates_for_children, :cascade_client

  def is_base_project?
    parent == root
  end

  def base_rates
    is_base_project? || parent.blank? ? rates : parent.rates
  end

  private

  def no_rates_for_children
    rates.clear if parent != root
  end

  def cascade_client
    if self.client_id.nil? and parent
      parent.self_and_ancestors.reverse.find do |a|
        self.client_id = a.client_id unless a.client_id.nil?
      end
    end
  end
end
