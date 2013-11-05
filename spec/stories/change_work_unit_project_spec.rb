require 'spec_helper'

steps "edit a work unit to move it from one project to another", :type => :feature do
  include SelectBoxItHelpers
  let! :client_1 do Factory(:client, :name => 'Foo, Inc.') end
  let! :client_2 do Factory(:client, :name => 'Bar, Inc.', :abbreviation => 'BAR') end
  let! :project_1 do Factory(:project, :client => client_1) end
  let! :project_2 do Factory(:project, :client => client_2) end
  let! :user      do Factory(:user, :current_project => project_1) end

  let! :work_unit do Factory(:work_unit, :project => project_1, :user => user) end

  it "log in as a user" do
    visit root_path
    fill_in "Login", :with => user.login
    fill_in "Password", :with => user.password
    click_button 'Login'
  end

  it "should show Project 1 selected in the project picker" do
    page.should have_selector("#project_#{project_1.id}.current")
  end

  it "should show the work unit in the dashboard" do
    within "#current_project" do
      page.should have_content(work_unit.notes)
    end
  end

  it "I click the 'Edit' link for that work unit" do
    within "#current_project" do
      page.find("a[href='/work_units/#{work_unit.id}/edit']").click
    end
  end

  it "should show a work unit edit form" do
    page.should have_selector("form#edit_work_unit_#{work_unit.id}")
  end

  it "should show a project <select> element" do
    within "form#edit_work_unit_#{work_unit.id}" do
      page.should have_select_box_selector("#work_unit_project_id")
    end
  end

  it "I change the project for the work unit" do
    select_box_it_select project_2.name, :from => "work_unit_project_id"
    click_button 'Submit'
  end

  it "should change the work unit's project in the DB" do
    work_unit.reload.project.should == project_2
  end

  it "I visit the home page" do
    visit root_path
  end

  it "should show Project 1 selected in the project picker" do
    page.should have_selector("#project_#{project_1.id}.current")
  end

  it "should not show the work unit in the dashboard" do
    within "#current_project" do
      page.should_not have_content(work_unit.notes)
    end
  end

  it "I select Project 2 from the project picker" do
    click_link "switch_to_project_#{project_2.id}"
  end

  it "should show the work unit in the dashboard" do
    within "#current_project" do
      page.should have_content(work_unit.notes)
    end
  end

end
