require 'spec_helper'

steps "User manually enters work units", :type => :feature do

  let! :client do FactoryGirl.create(:client, :name => 'Foo, Inc.') end
  let! :project do FactoryGirl.create(:project, :client => client, :name => "billable project") end
  let! :project_nonbillable do FactoryGirl.create(:project, :client => client, :billable => false, :name => "Non-Billable Project") end
  let! :user      do FactoryGirl.create(:user, :current_project => project) end

  before do
    Time.zone = 'Pacific Time (US & Canada)'

    @work_unit_count = WorkUnit.count
  end

  it "should login as a user" do
    visit root_path
    fill_in "Login", :with => user.login
    fill_in "Password", :with => user.password
    click_button 'Login'
    page.should have_link("Logout")
  end

  it "should have the name of the project" do
    within "h1#headline" do
      page.should have_content(project.name)
    end
  end

  it "should open and close the manual time entry form when relevant links are clicked" do
    page.should_not have_content("Enter/Record Hours")
    page.should_not have_content("(+ close manual time entry)")
    click_link "(+ show manual time entry)"
    page.should have_content("Enter/Record Hours")
    page.should_not have_content("(+ show manual time entry)")
    click_link "(+ close manual time entry)"
    page.should_not have_content("Enter/Record Hours")
    page.should have_content("(+ show manual time entry)")
    page.should_not have_content("(+ close manual time entry)")
  end

  it "should pre-check the billable box" do
    click_link "(+ show manual time entry)"
    page.should_not have_content("(+ show manual time entry)")
    page.should have_content("(+ close manual time entry)")
    within "#work_unit_form" do
      page.should have_checked_field( 'work_unit_billable' )
    end
  end

  it "when I fill in valid work unit information" do
    @start_time = Time.zone.now - 1.hour
    @stop_time = Time.zone.now

    fill_in "Start time", :with => @start_time.to_s(:short_datetime)
    fill_in "Stop time", :with => @stop_time.to_s(:short_datetime)
    fill_in "Notes", :with => "An hour of work"
    # this is not a click button cause at the immediate moment poltergeist
    # interprets
    # this button as obscured by the JS datepicker. the truly proper solution would
    # be to click somewhere else, then do a click_button once it's visible, but
    # honestly it doesn't seem worth it to spend a lot of time on this.
    find('#picker').click #this gets out of the JS datepicker
    find_button("Save Changes").click
  end

  it "should have the correct values for the work unit" do

    # although the section below checks the work unit manually, this integration test
    # is important because it forces the ajax request in capybara to complete so changes
    # are written to the database

    within("#recent_work") do
      page.should have_content("1.00")
    end

    @work_unit = WorkUnit.last
    @work_unit.hours.should == 1.00
    @work_unit.notes.should == "An hour of work"
    @work_unit.start_time.to_s.should == @start_time.to_s
    @work_unit.stop_time.to_s.should == @stop_time.to_s
    @work_unit.billable?.should == true

  end
  it "should show the work unit in recent work" do
    within "#recent_work" do
      page.should have_content("1.00")
      page.should have_css("a[href='/work_units/#{@work_unit.id}/edit']")
    end
  end

  it "should show the work unit in current project report" do
    within "#current_project" do
      page.should have_content("An hour of work")
    end
  end

  it "should pre-check the billable box for the next work unit" do
    within "#work_unit_form" do
      page.should have_checked_field( 'work_unit_billable' )
    end
  end

  it "when I fill in valid work unit information" do
    within "#new_work_unit" do
      find('#work_unit_billable').set(false)
    end
    fill_in "Start time", :with => (@start_time = (Time.zone.now - 2.hours)).to_s(:short_datetime)
    fill_in "Stop time", :with => (@stop_time = Time.zone.now).to_s(:short_datetime)
    fill_in "Notes", :with => "Two hours of unbillable work"
    # this is not a click button cause at the immediate moment poltergeist interprets
    # this button as obscured by the JS datepicker. the truly proper solution would
    # be to click somewhere else, then do a click_button once it's visible, but
    # honestly it doesn't seem worth it to spend a lot of time on this.
    find('#picker').click #this gets out of the JS datepicker
    find_button("Save Changes").click
  end

  it "should have the correct billable state for the work unit" do

    within("#recent_work") do
      page.should have_content("2.00")
    end

    @work_unit = WorkUnit.last
    @work_unit.notes.should == "Two hours of unbillable work"
    @work_unit.billable?.should == false
  end

  it "should log in to a non-billable project" do
    within "#project_picker" do
      click_link "switch_to_project_#{project_nonbillable.id}"
    end
  end

  it "should not pre-check the billable box" do
    click_link "(+ show manual time entry)"
    page.should_not have_content("(+ show manual time entry)")
    page.should have_content("(+ close manual time entry)")
    within "#work_unit_form" do
      page.should have_unchecked_field( 'work_unit_billable' )
    end
  end

  it "when I fill in valid work unit information" do
    within "#work_unit_form" do
      find('#work_unit_billable').set(true)
    end
    fill_in "Start time", :with => (@start_time = (Time.zone.now - 3.hours)).to_s(:short_datetime)
    fill_in "Stop time", :with => (@stop_time = Time.zone.now).to_s(:short_datetime)
    fill_in "Notes", :with => "Three hours of billable work"
    # this is not a click button cause at the immediate moment poltergeist interprets
    # this button as obscured by the JS datepicker. the truly proper solution would
    # be to click somewhere else, then do a click_button once it's visible, but
    # honestly it doesn't seem worth it to spend a lot of time on this.
    find('#picker').click #this gets out of the JS datepicker
    find_button("Save Changes").click
  end

  it "should have the correct billable state for the work unit" do

    within("#recent_work") do
      page.should have_content("3.00")
    end

    @work_unit = WorkUnit.last
    @work_unit.notes.should == "Three hours of billable work"
    @work_unit.billable?.should == true
  end

  it "should not pre-check the billable box" do
    within "#work_unit_form" do
      page.should have_unchecked_field( 'work_unit_billable' )
    end
  end

  it "when I fill in valid work unit information" do
    fill_in "Start time", :with => (@start_time = (Time.zone.now - 4.hours)).to_s(:short_datetime)
    fill_in "Stop time", :with => (@stop_time = Time.zone.now).to_s(:short_datetime)
    fill_in "Notes", :with => "Four hours of unbillable work"
    # this is not a click button cause at the immediate moment poltergeist interprets
    # this button as obscured by the JS datepicker. the truly proper solution would
    # be to click somewhere else, then do a click_button once it's visible, but
    # honestly it doesn't seem worth it to spend a lot of time on this.
    find('#picker').click #this gets out of the JS datepicker
    find_button("Save Changes").click
  end

  it "should have the correct billable state for the work unit" do
    within("#recent_work") do
      page.should have_content("4.00")
    end

    @work_unit = WorkUnit.last
    @work_unit.notes.should == "Four hours of unbillable work"
    @work_unit.billable?.should == false
  end
end
