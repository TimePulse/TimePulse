require 'spec_helper'

shared_steps "for a project rates task" do |opt_hash|
  opt_hash ||= {}

  let :admin do
    Factory(:admin)
  end

  let! :project do
    project = Factory(:project)
    project.rates.build
    project
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

  it "should have empty fields for a new rate" do
    page.should have_field('project[rates_attributes][0][name]')
    page.should have_field('project[rates_attributes][0][amount]')
  end

  it "should have link to add another rate" do
    page.should have_link('Add Rate')
  end

  it "should add another set of rate fields when 'add rate' link is clicked" do
    click_link('Add Rate')

    page.should have_field('project[rates_attributes][1][name]')
    page.should have_field('project[rates_attributes][1][amount]')
  end
end

steps "managing users in a rate group"
