require 'spec_helper'

describe "/projects/edit" do
  include ProjectsHelper

  before(:each) do
    assigns[:project] = @project = Factory(:project)
  end
                                       
  it "should succeed" do
    render
    response.should be_success    
  end
  it "renders the edit project form" do
    render
    response.should have_tag("form[action=#{project_path(@project)}][method=post]")
  end
end
