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

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Client do

  it "should create a new instance given valid attributes" do
    FactoryGirl.create(:client)
  end

  it "should require a name" do
    FactoryGirl.build(:client, :name => nil).should_not be_valid
  end

  it "should require a billing email" do
    FactoryGirl.build(:client, :billing_email => nil).should_not be_valid
  end


end
