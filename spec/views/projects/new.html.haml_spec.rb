require 'spec_helper'

describe "/projects/new" do
  include ProjectsHelper

  before(:each) do
    assign(:project, @project = FactoryGirl.build(:project))
    @project.rates.build
  end

  it "should succeed" do
    render
  end

  it "renders new project form" do
    render
    rendered.should have_selector("form[action='#{projects_path}'][method='post']") do |scope|
    end
  end

  it "renders inputs for a rate" do
    render
    rendered.should have_selector('input[name="project[rates_attributes][0][name]"]')
    rendered.should have_selector('input[name="project[rates_attributes][0][amount]"]')
  end
end
