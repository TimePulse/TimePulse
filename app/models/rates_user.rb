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
