require 'spec_helper'

describe "/projects/edit" do
  include ProjectsHelper

  before(:each) do
    assign(:project, @project = FactoryGirl.create(:project))
    @project.rates.build
  end

  it "should succeed" do
    render

  end
  it "renders the edit project form" do
    render
    rendered.should have_selector("form[action='#{project_path(@project)}'][method='post']")
    rendered.should have_selector('input[name="project[rates_attributes][0][name]"]')
    rendered.should have_selector('input[name="project[rates_attributes][0][amount]"]')
  end
end
