require 'spec_helper'

steps "clock in and out on projects", :type => :feature do

  let! :client_1 do FactoryGirl.create(:client, :name => 'Foo, Inc.') end
  let! :project_1 do FactoryGirl.create(:project, :client => client_1, :name => "Foo Project 1") end
  let! :project_2 do FactoryGirl.create(:project, :client => client_1, :name => "Foo Project 2", :billable => false ) end
  let! :user      do FactoryGirl.create(:user, :current_project => project_1) end

  let! :work_units do
    [ FactoryGirl.create(:work_unit, :project => project_1, :user => user),
      FactoryGirl.create(:work_unit, :project => project_1, :user => user),
      FactoryGirl.create(:work_unit, :project => project_1, :user => user),
    ]
  end

  before do
    Time.zone = 'Pacific Time (US & Canada)'
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
    page.should have_title(/clocked out/i)
    page.should have_xpath("/html/head/link[contains(@rel,'icon')][contains(@href,'clocked-out')]", :visible => false)
    page.should_not have_xpath "/html/head/link[contains(@rel,'icon')][contains(@href,'clocked-in')]", :visible => false
    within "#timeclock" do
      page.should have_content("You are not clocked in")
      page.should_not have_selector("#timeclock #task_elapsed")
      page.should_not have_selector("#annotation_input")
    end
  end

  it "user clicks on the clock in link in the timeclock" do
    within "#timeclock" do
      click_link "Clock in on [] Foo Project 1"
    end
  end

  it "should show a clock-in form and a clock" do
    page.should have_selector("form[action='/clock_out']")
    page.should have_selector("#timeclock #task_elapsed")
    page.should have_title(/clocked in/i)
    page.should have_xpath "/html/head/link[contains(@rel,'icon')][contains(@href,'clocked-in')]", :visible => false
    page.should_not have_xpath "/html/head/link[contains(@rel,'icon')][contains(@href,'clocked-out')]", :visible => false
    page.should have_selector("#annotation_input")
  end

  it "should have created an unfinished work unit in the DB" do
    WorkUnit.count.should == (@work_unit_count + 1)
    new_work_unit = WorkUnit.last
    new_work_unit.stop_time.should be_nil
    new_work_unit.project.should == project_1
    new_work_unit.activities.count.should == 0
  end

  it "should create annotation on clockout if content is present" do
    within "#timeclock" do
      fill_in "Annotations", :with => "Starting work on project"
      click_button "Clock Out"
    end
  end

  it "should show newly-created annotation under Recent Annotations" do
    within("#recent_annotations") do
      page.should have_content("Starting work on project")
    end
  end

  it "should show new annotation in recent work, within a project, under notes" do
    within("#recent_work") do
      find(".work_unit_label", match: :first).click
    end
    within(".work_unit_details") do
      page.should have_content("Starting work on project")
    end
  end

  it "should have an unclocked timeclock" do
    page.should have_title(/clocked out/i)
    page.should have_xpath "/html/head/link[contains(@rel,'icon')][contains(@href,'clocked-out')]", :visible => false
    page.should_not have_xpath "/html/head/link[contains(@rel,'icon')][contains(@href,'clocked-in')]", :visible => false
    within "#timeclock" do
      page.should have_content("You are not clocked in")
      page.should_not have_selector("#timeclock #task_elapsed")
    end
  end

  it "user clicks on the clock in link in the timeclock" do
    within "#timeclock" do
      click_link "Clock in on [] Foo Project 1"
    end
  end

  it "should show a clock-in form and a clock" do
    page.should have_selector("form[action='/clock_out']")
    page.should have_selector("#timeclock #task_elapsed")
  end

  it "should create annotation on enter" do
    fill_in "annotation_input", :with => "More work"
    find('#annotation_input').native.send_keys(:return)
  end

  it "should show newly-created annotation under Recent Annotations" do
    within("#recent_annotations") do
      page.should have_content("More work")
    end
  end

  it "should have created a new annotation in the DB" do
    new_work_unit = WorkUnit.last
    new_work_unit.activities.count.should == 1
    new_work_unit.activities.last.description.should == "More work"
  end

  it "should not have blank annotations" do
    find('#annotation_input').native.send_keys(:return)
  end

  it "should not have created a new annotation in the DB" do
    new_work_unit = WorkUnit.last
    new_work_unit.activities.count.should == 1
  end

  it "should create a second annotation on the same work unit" do
    fill_in "annotation_input", :with => "Worked all day"
    find('#annotation_input').native.send_keys(:return)
  end

  it "and I fill in nine hours and clock out" do
    within "#timeclock" do
      Timecop.travel(Time.zone.now + 10.hours)
      click_link("(+ show override tools)")
      fill_in "Hours", :with => '9.0'
      click_button "Clock Out"
    end
  end

  it "should show new annotation in recent work, within a project, under notes" do
    within("#recent_work") do
      find(".work_unit_label", match: :first).click
    end
    within(".work_unit_details") do
      page.should have_content("More work; Worked all day")
    end
  end

  it "should have an unclocked timeclock" do
    within "#timeclock" do
      page.should have_content("You are not clocked in")
      page.should_not have_selector("#timeclock #task_elapsed")
    end
  end

  it "should have created a completed work unit in the DB" do
    WorkUnit.count.should == @work_unit_count + 2
    new_work_unit = WorkUnit.last
    new_work_unit.stop_time.should be_within(10.seconds).of(Time.zone.now)
    new_work_unit.project.should == project_1
    new_work_unit.hours.should == 9.0
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

  it "user clicks on the clock in link in the timeclock" do
    Timecop.return
    within "#timeclock" do
      click_link "Clock in on [] Foo Project 1"
    end
  end

  it "should show a clock-in form and a clock" do
    page.should have_selector("form[action='/clock_out']")
    page.should have_selector("#timeclock #task_elapsed")
  end

  it "and I fill in a stop time of two hours ago (one hour from original, non-traveled time)" do
    within "#timeclock" do
      Timecop.travel(Time.zone.now + 3.hours)
      click_link("(+ show override tools)")
      fill_in "Stop Time", :with => (Time.zone.now - 2.hours).to_s(:short_datetime)
      fill_in "Annotations", :with => "I worked a few hours on this"
      click_button "Clock Out"
    end
  end

  it "should have an unclocked timeclock" do
    within "#timeclock" do
      page.should have_content("You are not clocked in")
      page.should_not have_selector("#timeclock #task_elapsed")
    end
  end

  it "should have created another completed work unit in the DB" do
    WorkUnit.count.should == @work_unit_count + 3
    new_work_unit = WorkUnit.last
    new_work_unit.stop_time.should be_within(10.seconds).of(Time.zone.now - 2.hours)
    new_work_unit.project.should == project_1
    new_work_unit.hours.should be_within(0.1).of(1.0)
  end

  it "user clocks in on a billable project" do
    within "#project_picker" do
      click_link("Clock in on [] Foo Project 1")
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
      click_link("Clock in on [] Foo Project 2")
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

  after do
    Timecop.return
  end

end
