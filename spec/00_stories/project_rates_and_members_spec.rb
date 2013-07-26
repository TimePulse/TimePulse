require 'spec_helper'

shared_steps "for a project rates task" do |opt_hash|
  opt_hash ||= {}

  let :admin do
    Factory(:admin)
  end

  let :project do
    Factory(:project)
  end

  it "should login as an admin" do
    visit root_path
    fill_in "Login", :with => admin.login
    fill_in "Password", :with => admin.password
    click_button 'Login'
    page.should have_link("Logout")
  end

  it "should go to projects" do
    click_link "Projects"
    page.should have_link("New Project")
  end
end

steps "adding rates to a project", :type => :feature do
  perform_steps "for a project rates task"

  it "should create a new project" do
    click_link "New Project"
  end

  it "should have empty form fields for a new rate"

  it "should submit new rate"

  it "should display new rate"
end
