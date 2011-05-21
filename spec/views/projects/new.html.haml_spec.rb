require 'spec_helper'

describe "/projects/new" do
  include ProjectsHelper

  before(:each) do
    assigns[:project] = Factory.build(:project)
  end
  it "should succeed" do
    render
    response.should be_success
  end

  it "renders new project form" do
    render

    response.should have_tag("form[action=?][method=post]", projects_path) do
    end
  end
end
