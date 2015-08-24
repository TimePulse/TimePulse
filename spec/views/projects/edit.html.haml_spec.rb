require 'spec_helper'

describe "/projects/edit" do
  include ProjectsHelper


  before(:each) do
    @project = FactoryGirl.create(:project)
    @project_form = ProjectForm.find(@project)
    @project_form.append_new_rate

    assign(:project_form, @project_form)

    view.stub(:action_name).and_return("edit")
  end

  it "should succeed" do
    render

  end
  it "renders the edit project form" do
    render
    rendered.should have_selector("form[action='#{project_path(@project)}'][method='post']")
    rendered.should have_selector('input[name="project_form[rates_attributes][0][name]"]')
    rendered.should have_selector('input[name="project_form[rates_attributes][0][amount]"]')
  end
end
