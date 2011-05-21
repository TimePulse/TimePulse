require 'spec_helper'

describe "/clock_time/create" do
  before(:each) do
    assigns[:work_unit] = Factory(:work_unit)
    assigns[:project] = Factory(:project)
    render 'clock_time/create'
  end

  it "should succeed" do
    response.should be_success  
  end
end
