require 'spec_helper'

steps "clock in and out on projects", :type => :feature, :snapshots_into => "link" do

  let! :client_1 do
    FactoryGirl.create(:client, :name => 'Foo, Inc.', :abbreviation => 'FOO') end
  let! :client_2 do FactoryGirl.create(:client, :name => 'Bar, Inc.', :abbreviation => 'BAR') end
  let! :project_2 do FactoryGirl.create(:project, :client => client_1, :name => "project 2") end
  let! :project_3 do FactoryGirl.create(:project, :client => client_2, :name => 'project 3') end
  let! :user      do FactoryGirl.create(:user, :current_project => project_2) end

  let! :work_units do
    [ FactoryGirl.create(:work_unit, :project => project_2, :user => user),
      FactoryGirl.create(:work_unit, :project => project_2, :user => user),
      FactoryGirl.create(:work_unit, :project => project_2, :user => user),
    ]
  end

  it "should login as a user" do
    visit root_path
    fill_in "Login", :with => user.login
    fill_in "Password", :with => user.password
    click_button 'Login'
    page.should have_link("Logout")
    @work_unit_count = WorkUnit.count
  end

  it "should have an unclocked timeclock for project 2" do
    within "#timeclock" do
      page.should have_content("You are not clocked in")
      page.should_not have_selector("#timeclock #task_elapsed")
      page.should     have_content(project_2.name)
      page.should_not have_content(project_3.name)
    end
  end

  it "Project 2 should be selected in the project picker" do
    page.should have_selector("#project_#{project_2.id}.current")
  end

  it "Project 3 should be in the project picker" do
    page.should have_selector("#project_#{project_3.id}")
  end

  it "Project 3 should not be selected in the project picker" do
    page.should_not have_selector("#project_#{project_3.id}.current")
  end

  it "I click the clock for project 3 in the picker" do
    within "#picker" do
      click_link("Clock in on [BAR] project 3")
    end

  end

  it "should show project 3 in the timeclock" do
    within "#timeclock" do
      page.should have_content(project_3.name)
    end
  end

  it "should show a clock-out form and a clock" do
    within "#timeclock" do
      page.should have_selector("form[action='/clock_out']")
      page.should have_selector("#task_elapsed")
    end
  end

  it "should have created an unfinished work unit in the DB" do
    WorkUnit.count.should == @work_unit_count +1
    @new_work_unit = WorkUnit.last
    @new_work_unit.stop_time.should be_nil
    @new_work_unit.project.should == project_3
  end

  it "I click the clock for project 2 in the picker" do
    within "#project_2" do
      click_link("Clock in on [FOO] project 2")
    end
  end

  it "should show project 2 in the timeclock" do
    within "#timeclock" do
      page.should have_content(project_2.name)
    end
  end

  it "should show a clock-out form and a clock" do
    within "#timeclock" do
      page.should have_selector("form[action='/clock_out']")
      page.should have_selector("#task_elapsed")
    end
  end

  it "should have completed the previous work unit in the DB" do
    @new_work_unit.reload.should be_completed
  end

  it "should have created an unfinished work unit in the DB" do
    WorkUnit.count.should == @work_unit_count + 2
    new_work_unit = WorkUnit.last
    new_work_unit.stop_time.should be_nil
    new_work_unit.project.should == project_2
  end

  it "should show the created work unit in 'Recent Work'" do
    within "#recent_work" do
      page.should have_content(project_2.name)
    end
  end
end
