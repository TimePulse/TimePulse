require 'spec_helper'

describe "/projects/edit" do
  include ProjectsHelper

  before(:each) do
    assign(:project, @project = Factory(:project))
  end
                                       
  it "should succeed" do
    render
        
  end
  it "renders the edit project form" do
    render
    rendered.should have_selector("form[action=#{project_path(@project)}][method='post']")
  end
end
