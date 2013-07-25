# == Schema Information
#
# Table name: rates_users
#
#  rate       :integer(4)
#  user       :integer(4)
#

class RatesUser < ActiveRecord::Base
  belongs_to :rate
  belongs_to :user
end

