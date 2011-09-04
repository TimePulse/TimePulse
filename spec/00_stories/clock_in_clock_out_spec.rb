require 'spec_helper'

steps "clock in and out on projects", :type => :request do

  let! :client_1 do Factory(:client, :name => 'Foo, Inc.') end
  let! :project_1 do Factory(:project, :client => client_1) end
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

  it "should have an unclocked timeclock" do
    within "#timeclock" do
      page.should have_content("You are not clocked in")
      page.should_not have_selector("#timeclock #task_elapsed")
    end
  end

  it "user clicks on the clock in link in the timeclock" do
    click_link "Clock in on #{project_1.name}"
  end 

  it "should show a clock-in form and a clock" do
    page.should have_selector("form[action='/clock_out']")    
    page.should have_selector("#timeclock #task_elapsed")
  end

  it "should have created an unfinished work unit in the DB" do
    WorkUnit.count.should == @work_unit_count +1 
    new_work_unit = WorkUnit.last
    new_work_unit.stop_time.should be_nil
    new_work_unit.project.should == project_1
  end

  it "should clock out with a message" do
    fill_in "Notes", :with => "Did a little work on project #1"
    within("#timeclock"){ click_button "Clock Out" }
  end


  it "should have an unclocked timeclock" do
    within "#timeclock" do
      page.should have_content("You are not clocked in")
      page.should_not have_selector("#timeclock #task_elapsed")
    end
  end

end
