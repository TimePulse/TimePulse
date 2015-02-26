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
      :project => FactoryGirl.create(:project)
    }
  end

  it "should create a new instance given valid attributes" do
    Rate.create!(@valid_attributes)
  end

  it "should allow users to be associated" do
    rate = Rate.new

    rate.users << FactoryGirl.create(:user)

    rate.users.size.should == 1
  end

  it "should clear user list before record is destroyed" do
    RatesUser.all.should be_empty

    user1 = FactoryGirl.create(:user, :name => 'User 1')
    user2 = FactoryGirl.create(:user, :name => 'User 2')
    rate = Rate.create!(@valid_attributes)
    rate.users << user1
    rate.users << user2

    RatesUser.all.size.should == 2

    rate.destroy

    RatesUser.all.should be_empty
  end

  it "should allow rates to include decimals" do
    decimal_rate = Rate.create!(@valid_attributes.merge({:amount=>100.50}))
    expect(decimal_rate.reload.amount).to eq(100.50)
  end
end
