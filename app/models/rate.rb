# == Schema Information
#
# Table name: rates
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  value      :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

class Rate < ActiveRecord::Base
  belongs_to :project
  has_many :rates_users
  has_many :users, :through => :rates_users

  attr_accessible :name, :value
end

