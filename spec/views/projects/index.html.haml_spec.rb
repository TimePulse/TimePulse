require 'spec_helper'

describe "/projects/index" do
  include ProjectsHelper

  before(:each) do
    authenticate(:user)
    assigns[:projects] = [ Factory(:project), Factory(:project) ]
  end

  it "should succeed" do
    render
    response.should be_success
  end
end
