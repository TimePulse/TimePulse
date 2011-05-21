require 'spec_helper'

describe "/projects/index" do
  include ProjectsHelper

  before(:each) do
    authenticate(:user)
    assign(:projects, [ Factory(:project), Factory(:project) ])
  end

  it "should succeed" do
    render
    
  end
end
