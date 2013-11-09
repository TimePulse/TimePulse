require 'spec_helper'

steps "clock in and out on projects", :type => :feature do

  let! :client_1 do FactoryGirl.create(:client, :name => 'Foo, Inc.') end
  let! :project_1 do FactoryGirl.create(:project, :client => client_1) end
  let! :project_2 do FactoryGirl.create(:project, :client => client_1, :billable => false ) end
  let! :user      do FactoryGirl.create(:user, :current_project => project_1) end

  let! :work_units do
    [ FactoryGirl.create(:work_unit, :project => project_1, :user => user),
      FactoryGirl.create(:work_unit, :project => project_1, :user => user),
      FactoryGirl.create(:work_unit, :project => project_1, :user => user),
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
    within "#timeclock" do
      click_link "clock_in_on_project_#{project_1.id}"
    end
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
    within "#timeclock" do
      fill_in "Notes", :with => "Did a little work on project #1"
      click_button "Clock Out"
    end
  end


  it "should have an unclocked timeclock" do
    within "#timeclock" do
      page.should have_content("You are not clocked in")
      page.should_not have_selector("#timeclock #task_elapsed")
    end
  end


  it "user clicks on the clock in link in the timeclock" do
    within "#timeclock" do
      click_link "clock_in_on_project_#{project_1.id}"
    end
    @new_work_unit = WorkUnit.last
  end

  it "user clocks out with hours set unreasonably high" do
    pending "Waiting for implementation of validation checking on clock-out"
    within("#timeclock") do
      click_link("(+ show override tools)")
      fill_in "Hours", :with => '9.0'
      fill_in "Notes", :with => "I worked all day on this"
      click_button "Clock Out"
    end
  end

  it "should show a flash error" do
    pending "Waiting for implementation of validation checking on clock-out"
    page.should have_selector(".flash.error")
  end

  it "should still show the timeclock" do
    pending "Waiting for implementation of validation checking on clock-out"
    page.should have_selector("form[action='/clock_out']")
    page.should have_selector("#timeclock #task_elapsed")
  end

  it "should not mark the work unit completed" do
    pending "Waiting for implementation of validation checking on clock-out"
    @new_work_unit.reload.should_not be_completed
  end

  it "when the work unit was started ten hours ago ago" do
    @new_work_unit.update_attribute(:start_time, Time.now - 10.hours)
  end

  it "and I fill in nine hours and clock out" do
    within "#timeclock" do
      click_link("(+ show override tools)")
      fill_in "Hours", :with => '9.0'
      fill_in "Notes", :with => "I worked all day on this"
      click_button "Clock Out"
    end
  end

  it "should have an unclocked timeclock" do
    within "#timeclock" do
      page.should have_content("You are not clocked in")
      page.should_not have_selector("#timeclock #task_elapsed")
    end
  end


  it "should have created an completed work unit in the DB" do
    WorkUnit.count.should == @work_unit_count + 2
    new_work_unit = WorkUnit.last
    new_work_unit.stop_time.should be_within(10.seconds).of(Time.now)
    new_work_unit.project.should == project_1
    new_work_unit.notes.should == "I worked all day on this"
    #new_work_unit.hours.should == 9.0
  end

  it "should show the created work unit in 'Recent Work'" do
    within "#recent_work" do
      page.should have_content("9.00")
    end
  end

  it "should update 'Hours this week' with the created work units" do

    within "#this_week" do
      hours = WorkUnit.this_week.map{|wu|wu.hours}.sum
      page.should have_content("%.2f" % hours)
    end
  end

  it "user clocks in on a billable project" do
    within "#project_picker" do
      find_link("clock_in_on_project_#{project_1.id}").trigger('click')
    end
  end

  it "should have created a billable work unit in the DB" do
    within "#timeclock" do
      page.should have_checked_field "work_unit_billable"
    end
    WorkUnit.last.billable?.should == true
  end

  it "should be able to make a work unit non-billable" do
    within "#timeclock" do
      uncheck "work_unit_billable"
      click_button "Clock Out"
    end
    within "#timeclock" do
      page.should have_content("You are not clocked in.")
    end
    WorkUnit.last.billable?.should == false
  end

  it "user clocks in on a non-billable project" do
    within "#project_picker" do
      find_link("clock_in_on_project_#{project_2.id}").trigger('click')
    end
  end

  it "should have created a non-billable work unit in the DB" do
    within "#timeclock" do
      page.should have_unchecked_field "work_unit_billable"
    end
    WorkUnit.last.billable?.should == false
  end

  it "should be able to make a work unit billable" do
    within "#timeclock" do
      check "work_unit_billable"
      click_button "Clock Out"
    end
    within "#timeclock" do
      page.should have_content("You are not clocked in.")
    end
    WorkUnit.last.billable?.should == true
  end
end
