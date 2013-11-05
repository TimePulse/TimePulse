require 'spec_helper'

steps "clock out after a while", :type => :feature do

  let! :client_1 do FactoryGirl.create(:client, :name => 'Foo, Inc.') end
  let! :project_1 do FactoryGirl.create(:project, :client => client_1) end
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
  end

  it "if I'm clocked in as of an hour ago and reload the page" do
    @work_unit = WorkUnit.new(:project => project_1, :start_time => 1.hour.ago, :stop_time => nil)
    @work_unit.user = user
    @work_unit.save
    visit root_path
  end

  it "should show a clock-in form and a clock" do
    page.should have_selector("form[action='/clock_out']")
    page.should have_selector("#timeclock #task_elapsed")
  end


  it "when I clock out with a message" do
    within "#timeclock" do
      fill_in "Notes", :with => "Did a an hour's work on project #1"
      click_button "Clock Out"
    end
  end

  it "should have an unclocked timeclock" do
    within "#timeclock" do
      page.should have_content("You are not clocked in")
      page.should_not have_selector("#timeclock #task_elapsed")
    end
  end

  it "the work unit should be clocked out with an end time" do
    @work_unit.reload.hours.should be_within(0.01).of(1.00)
    @work_unit.stop_time.should be_within(2.seconds).of(Time.now)
  end


  it "should list the work unit in recent work" do
    within "#recent_work" do
      #within ".work_unit_#{@work_unit.id}" do
      page.should have_css("a[href='#{edit_work_unit_path(@work_unit)}']")
    end
  end


end

