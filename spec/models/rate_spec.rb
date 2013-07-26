# == Schema Information
#
# Table name: rates
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  rate       :integer(4)
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe Rate do
  before(:each) do
    @valid_attributes = {
      :name => 'Rate 0',
      :amount => 100,
      :project => Factory(:project)
    }
  end

  it "should create a new instance given valid attributes" do
    Rate.create!(@valid_attributes)
  end

  it "should allow users to be aassociated" do
    rate = Rate.new

    rate.users << Factory(:user)

    rate.users.size.should == 1
  end
end
