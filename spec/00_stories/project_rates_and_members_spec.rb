require 'spec_helper'

shared_steps "for a project rates task" do |opt_hash|
  opt_hash ||= {}

  let :admin do
    Factory(:admin)
  end

  let! :rate do
    Factory(:rate)
  end

  let! :project do
    project = Factory(:project)
  end

  let! :all_users do
    [Factory(:user)]
  end

  let! :active_user do
    Factory(:user, :name => "Active User")
  end

  let! :inactive_user do
    Factory(:user, { :name => "Inactive User", :inactive => true })
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
    select 'root', :from => 'project[parent_id]'

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

steps "managing users in a rate group", :type => :feature do
  perform_steps "for a project rates task"

  it "should have rate form and available user list." do
    first(:link, 'Show').click

    page.should have_selector('.available-users-container .rates-user')
  end

  it "should only show active users" do
    #page.should have_selector("data-user-id", :text => "#{active_user.id}")
    page.should have_content("#{active_user.name}")
    page.should_not have_content("#{inactive_user.name}")
  end

  it "should add a user to a rate" do
    item = first('.available-users-container .rates-user')
    item.drag_to first('.rates-users-container')

    page.should have_selector('.rates-users-container .rates-user')
  end

  it "should remove a user from a rate" do
    item = first('.rates-users-container .rates-user')
    item.drag_to first('.available-users-container')

    page.should have_selector('.available-users-container .rates-user')
  end
end
