require 'spec_helper'

describe "/projects/new" do
  include ProjectsHelper

  before(:each) do
    assign(:project, Factory.build(:project))
  end
  it "should succeed" do
    render
    
  end

  it "renders new project form" do
    render

    rendered.should have_selector("form[action=?][method='post']", projects_path) do |scope|
    end
  end
end
