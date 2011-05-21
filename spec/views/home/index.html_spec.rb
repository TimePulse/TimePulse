require 'spec_helper'

describe "/home/index" do
  before(:each) do 
    @user = authenticate(:user)
    Factory(:work_unit, :user => @user)
    Factory(:work_unit, :user => @user)
    render 'home/index'
  end

  it "should succeed" do
    response.should be_success
  end
end
