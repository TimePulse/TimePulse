require 'spec_helper'
RSpec.steps "Admin archives a project", :type => :feature do
  let! :client_1 do FactoryGirl.create(:client, :name => 'Foo, Inc.', :abbreviation => 'FOO') end
  let! :client_2 do FactoryGirl.create(:client, :name => 'Bar, Inc.', :abbreviation => 'BAR') end
  let! :project_2 do FactoryGirl.create(:project, :client => client_1, :name => "Project 2 base") end
  let! :project_2a do FactoryGirl.create(:project, :parent => project_2, :name => "Project 2a") end
  let! :project_2b do FactoryGirl.create(:project, :parent => project_2, :name => "Project 2b") end

  let! :project_3 do FactoryGirl.create(:project, :client => client_2, :name => 'Project 3 base') end
  let! :project_3a do FactoryGirl.create(:project, :parent => project_3, :name => 'Project 3a') end
  let! :admin do FactoryGirl.create(:admin) end

  it "should login as the admin" do
    visit root_path
    fill_in "Login", :with => admin.login
    fill_in "Password", :with => admin.password
    click_button 'Login'
  end

  it "and I expand all projects" do
    page.should have_content('Logout')
    all(".expand-widget").each do |expand_button|
      expand_button.click
    end
  end

  it "should show all the projects in the picker" do
    within '#project_picker' do
      page.should have_content('Project 2 base')
      page.should have_content('Project 2a')
      page.should have_content('Project 2b')
      page.should have_content('Project 3 base')
      page.should have_content('Project 3a')
    end
  end

  it "when I visit the projects page" do
    click_link "Projects"
  end

  it "and I click to edit the project" do
    within "#project_#{project_2.id}" do
      click_link "Edit"
    end
  end

  it "and I check archived" do
    check "Archived"
  end

  it "and I submit the form" do
    click_button "Submit"
  end

  it "then when I revisit the dashboard" do
    page.should have_content('Logout')
    visit root_path
  end

  it "and I expand all projects" do
    page.should have_content('Logout')
    all(".expand-widget").each do |expand_button|
      expand_button.click
    end
  end

  it "should show the other projects in the picker" do
    within '#project_picker' do
      page.should have_content('Project 3 base')
      page.should have_content('Project 3a')
    end
  end

  it "should not show the archived projects in the picker" do
    within '#project_picker' do
      page.should_not have_content('Project 2 base')
    end
  end

  it "should not show the archived projects' descendants in the picker" do
    within '#project_picker' do
      page.should_not have_content('Project 2a')
      page.should_not have_content('Project 2b')
    end
  end
end
