require 'spec_helper'

steps "edit a work unit to move it from one project to another", :type => :feature, :snapshots_into => "edit_work_unit" do
  include SelectBoxItHelpers
  let! :client_1 do FactoryGirl.create(:client, :name => 'Foo, Inc.') end
  let! :client_2 do FactoryGirl.create(:client, :name => 'Bar, Inc.', :abbreviation => 'BAR') end
  let! :project_1 do
    project = FactoryGirl.build(:project)
    project.client = client_1
    project.save
    project
  end
  let! :project_2 do
    project = FactoryGirl.build(:project)
    project.client = client_2
    project.save
    project
  end
  let! :user      do
    u = FactoryGirl.build(:user)
    u.current_project = project_1
    u.save
    u
  end

  let! :work_unit do
    wu = FactoryGirl.build(:work_unit)
    wu.project = project_1
    wu.user = user
    wu.save
    wu
  end

  it "log in as a user" do
    visit root_path
    fill_in "Login", :with => user.login
    fill_in "Password", :with => user.password
    click_button 'Login'
  end

  it "should show Project 1 selected in the project picker" do
    p project_1
    p project_2
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

  it "if I visit the work_unit's page" do
    visit "/work_units/#{work_unit.id}"
  end

  it "should change the work unit's project in the DB" do
    page.should have_content("Project: #{project_2.id}")
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
