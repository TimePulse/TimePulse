require 'spec_helper'

describe "/projects/index" do
  include ProjectsHelper

  before(:each) do
    authenticate(:user)
    Factory(:project)
    assign(:root_project, Project.root)
  end

  it "should succeed" do
    render

  end
end
