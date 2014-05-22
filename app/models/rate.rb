# == Schema Information
#
# Table name: houlry_rates
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  amount     :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

# Rates added to sub-project will override parent project rates completely.
# Users may see rates disappear from a child when adding rates specifically for a child.

class Rate < ActiveRecord::Base
  belongs_to :project
  has_many :rates_users
  has_many :users, :through => :rates_users

  validates_presence_of :name, :amount

  before_destroy :clear_users

  private

  def clear_users
    users.clear
  end
end

# == Schema Information
#
# Table name: rates_users
#
#  rate_id     :integer(4)
#  user_id     :integer(4)
#

class RatesUser < ActiveRecord::Base
  belongs_to :rate
  belongs_to :user
end

