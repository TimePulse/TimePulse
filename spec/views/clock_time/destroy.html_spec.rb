require 'spec_helper'

describe "/clock_time/destroy" do
  before(:each) do
    render 'clock_time/destroy'
  end

  it "should succeed" do
    response.should be_success  
  end
end
