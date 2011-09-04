require 'spec_helper'

steps "clock in and out on projects", :type => :request do

  let! :client_1 do Factory(:client, :name => 'Foo, Inc.', :abbreviation => 'FOO') end
  let! :client_2 do Factory(:client, :name => 'Bar, Inc.', :abbreviation => 'BAR') end
  let! :project_1 do Factory(:project, :client => client_1) end
  let! :project_2 do Factory(:project, :client => client_2) end
  let! :user      do Factory(:user, :current_project => project_1) end

  let! :work_units do
    [ Factory(:work_unit, :project => project_1, :user => user),
      Factory(:work_unit, :project => project_1, :user => user),
      Factory(:work_unit, :project => project_1, :user => user),
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

  it "should have an unclocked timeclock for project 1" do
    debugger
    within "#timeclock" do
      page.should have_content("You are not clocked in")
      page.should_not have_selector("#timeclock #task_elapsed")
      page.should     have_content(project_1.name)
      page.should_not have_content(project_2.name)
    end
  end

  it "Project 1 should be selected in the project picker" do
    page.should have_selector("#project_1.current")
  end

  it "Project 2 should not be selected in the project picker" do
    page.should_not have_selector("#project_2.current")
  end

  it "i click the clock for project 2 in the picker" do
    within "#picker" do
      click_link "clock_in_on_project_#{project_2.id}"
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
      page.should have_selector("#timeclock #task_elapsed")
    end
  end

  it "should have created an unfinished work unit in the DB" do
    WorkUnit.count.should == @work_unit_count +1 
    @new_work_unit = WorkUnit.last
    @new_work_unit.stop_time.should be_nil
    @new_work_unit.project.should == project_2
  end

  it "I click the clock for project 1 in the picker" do
    within "#picker" do
      click_link "clock_in_on_project_#{project_1.id}"
    end 
  end

  it "should show project 1 in the timeclock" do
    within "#timeclock" do 
      page.should have_content(project_2.name)
    end
  end

  it "should show a clock-out form and a clock" do 
    within "#timeclock" do
      page.should have_selector("form[action='/clock_out']")    
      page.should have_selector("#timeclock #task_elapsed")
    end
  end

  it "should have completed the previous work unit in the DB" do
    @new_work_unit.reload.should be_completed
  end

  it "should have created an unfinished work unit in the DB" do
    WorkUnit.count.should == @work_unit_count + 2
    new_work_unit = WorkUnit.last
    new_work_unit.stop_time.should be_nil
    new_work_unit.project.should == project_1
  end

  it "should show the created work unit in 'Recent Work'" do
    within "#recent_work" do
      page.should have_content(project_2.name)
    end
  end

end
