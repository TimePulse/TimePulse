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

  # default_scope :joins => :client

  validates_presence_of :name
  cascades :client, :account, :clockable

  attr_accessible :name, :account, :description, :parent_id, :parent, :client_id, :client, :clockable, :billable, :flat_rate, :archived
end

