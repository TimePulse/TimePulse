# == Schema Information
#
# Table name: clients
#
#  id            :integer(4)      not null, primary key
#  name          :string(255)
#  billing_email :string(255)
#  address_1     :string(255)
#  address_2     :string(255)
#  city          :string(255)
#  state         :string(255)
#  postal        :string(255)
#  abbreviation  :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#

class Client < ActiveRecord::Base
  validates_presence_of :name
  validates_presence_of :billing_email

  has_many :projects
  has_many :invoices

end
