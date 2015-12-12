require 'spec_helper'

steps "User manually enters work units", :type => :feature, :firefox => false do

  let! :client do FactoryGirl.create(:client, :name => 'Foo, Inc.') end
  let! :project do FactoryGirl.create(:project, :client => client, :name => "billable project") end
  let! :project_nonbillable do FactoryGirl.create(:project, :client => client, :billable => false, :name => "Non-Billable Project") end
  let! :project_nonclockable do FactoryGirl.create(:project, :client => client, :clockable => false, :name => "Non-Clockable Project") end
  let! :user      do FactoryGirl.create(:user, :current_project => project) end

  let! :work_unit do FactoryGirl.create(:in_progress_work_unit, :user => user, :project => project) end


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
      page.should have_content("WORK UNIT ENTRY")
    end
  end

  it "should switch to manual time entry when tab is clicked" do
    within "#work_unit_entry" do
      page.should have_content("Manual Time Entry")
      find('#work_unit_entry_tp_manual_time_entry_tab').click
    end
  end

  # XXX Firefox can't find #work_unit_form, which breaks firefox runs
  # Travis is only Firefox so...
  it "should have the name of the project in manual time entry" do
    within "#work_unit_form" do
      within "h2.toggler" do
        page.should have_content(project.name.upcase)
      end
    end
  end

  it "should pre-check the billable box" do
    within "#work_unit_form" do
      page.should have_checked_field( 'manual_work_unit_billable' )
    end
  end

  it "when I fill in valid work unit information" do
    @start_time = Time.zone.now - 1.hour
    @stop_time = Time.zone.now

    fill_in "Start time", :with => @start_time.to_s(:short_datetime)
    fill_in "Stop time", :with => @stop_time.to_s(:short_datetime)
    fill_in "Work Unit Annotations", :with => "An hour of work"
    first(:xpath, '//button[contains("Done",text())]').try(:click)
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
    @work_unit.start_time.to_s.should == @start_time.to_s
    @work_unit.stop_time.to_s.should == @stop_time.to_s
    @work_unit.billable?.should == true

  end

  it "should show newly-created annotation under Recent Annotations" do
    within("#recent_annotations") do
      page.should have_content("An hour of work")
    end
  end

  it "should show the work unit in recent work" do
    within "#recent_work" do
      page.should have_content("1.00")
      page.should have_css("a[href='/work_units/#{@work_unit.id}/edit']")
    end
  end

  # it "should show the work unit in current project report" do
  #   within "#current_project" do
  #     page.should have_content("An hour of work")
  #   end
  # end

  it "should pre-check the billable box for the next work unit" do
    within "#work_unit_form" do
      page.should have_checked_field( 'manual_work_unit_billable' )
    end
  end

  it "when I fill in valid work unit information" do
    within "#manual_new_work_unit" do
      find('#manual_work_unit_billable').set(false)
    end
    fill_in "Start time", :with => (@start_time = (Time.zone.now - 2.hours)).to_s(:short_datetime)
    fill_in "Stop time", :with => (@stop_time = Time.zone.now).to_s(:short_datetime)
    fill_in "Work Unit Annotations", :with => "Two hours of unbillable work"
    first(:xpath, '//button[contains("Done",text())]').try(:click)
    find_button("Save Changes").click
  end

  it "should have the correct billable state for the work unit" do

    within("#recent_work") do
      page.should have_content("2.00")
    end

    @work_unit = WorkUnit.last
    @work_unit.activities[0]['description'].should == "Two hours of unbillable work"
    @work_unit.billable?.should == false
  end

  it "should log in to a non-billable project" do
    within "#project_picker" do
      click_link "switch_to_project_#{project_nonbillable.id}"
    end
  end

  it "should have the name of the nonbillable project in manual time entry" do
    within "#work_unit_form" do
      within "h2.toggler" do
        page.should have_content(project_nonbillable.name.upcase)
      end
    end
  end

  it "should display the manual time entry work unit form" do
    page.should have_content("Enter/Record Hours:")
  end

  it "should not pre-check the billable box" do
    within "#work_unit_form" do
      page.should_not have_checked_field('#manual_work_unit_billable')
    end
  end

  it "when I fill in valid work unit information" do
    within "#work_unit_form" do
      find('#manual_work_unit_billable').set(true)
    end
    fill_in "Start time", :with => (@start_time = (Time.zone.now - 3.hours)).to_s(:short_datetime)
    fill_in "Stop time", :with => (@stop_time = Time.zone.now).to_s(:short_datetime)
    fill_in "Work Unit Annotations", :with => "Three hours of billable work"
    first(:xpath, '//button[contains("Done",text())]').try(:click)
    find_button("Save Changes").click
  end

  it "should have the correct billable state for the work unit" do

    within("#recent_work") do
      page.should have_content("3.00")
    end
    @work_unit = WorkUnit.last
    @work_unit.billable?.should == true
  end

  it "should not pre-check the billable box" do
    within "#work_unit_form" do
      page.should have_unchecked_field( 'manual_work_unit_billable' )
    end
  end

  it "when I fill in valid work unit information" do
    fill_in "Start time", :with => (@start_time = (Time.zone.now - 4.hours)).to_s(:short_datetime)
    fill_in "Stop time", :with => (@stop_time = Time.zone.now).to_s(:short_datetime)
    fill_in "Work Unit Annotations", :with => "Four hours of unbillable work"
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
    @work_unit.billable?.should == false
  end

  it "should log in to a non-clockable project" do
    within "#project_picker" do
      click_link "switch_to_project_#{project_nonclockable.id}"
    end
  end

  it "should not display input fields in manual time entry for non-clockable project" do
    page.should have_content("This is not a clockable project.")
    page.should_not have_field('manual_work_unit_start_time')
  end

end
