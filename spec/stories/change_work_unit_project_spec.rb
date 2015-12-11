require 'spec_helper'

steps "edit a work unit to move it from one project to another", :type => :feature, :firefox => false do
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
    project.name = "Special Project"
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
    wu = FactoryGirl.create(:work_unit_with_annotation)
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
    page.should have_selector("#project_#{project_1.id}.current")
  end

  # XXX Firefox can't find #work_unit_form, which breaks firefox runs
  # Travis is only Firefox so...
  it "I show the manual entry form" do
    find('#work_unit_entry_tp_manual_time_entry_tab').click
    within "#work_unit_form" do
      within "h2.toggler" do
        page.should have_content(project_1.name.upcase)
      end
    end
  end

  it "should show the work unit in the dashboard" do
    within "#work_report_tp_work_units_pane" do
      page.should have_content(work_unit.notes)
    end
  end

  it "I click the 'Edit' link for that work unit" do
    within "#work_report_tp_work_units_pane" do
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
    select_box_it_select "Special Project", :from => "work_unit_project_id"
    click_button 'Submit'
    page.should have_link("Edit")
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

  # it "I show the manual entry form" do
  #   click_link "(+ show manual time entry)"
  #   expect(page).to have_content("MANUAL TIME ENTRY")
  # end

  it "should not show the work unit in the dashboard" do
    within "#work_report_tp_work_units_pane" do
      page.should_not have_content(work_unit.notes)
    end
  end

  it "I select Project 2 from the project picker" do
    click_link "switch_to_project_#{project_2.id}"
  end

  it "should show the work unit in the dashboard" do
    within "#work_report_tp_work_units_pane" do
      page.should have_content(work_unit.notes)
    end
  end

end
