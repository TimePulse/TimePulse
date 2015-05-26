require 'spec_helper'

steps "see user work units on calendar", :type => :feature, :js => true do
  # before :all do
  #   Timecop.travel(Time.zone.parse("May 19, 2015 14:00"))
  # end
  let! :admin do FactoryGirl.create(:admin ) end
  let! :admin_work_units do
    puts Time.now
    FactoryGirl.create(:work_unit, :user => admin, :hours => 4, :notes => "Number1")
  end
  let! :user do FactoryGirl.create(:user ) end
  let! :user_work_units do
    FactoryGirl.create(:work_unit, :hours => 7, :user => user, :notes => "Number2")
  end
  let! :admin_work_units_in_range do
    FactoryGirl.create(:work_unit, :start_time => Time.now-4.hours, :stop_time => Time.now-3.hours, :hours => 1, :user => admin, :notes => "Number3")
  end
  let! :admin_work_units_out_of_range do
    FactoryGirl.create(:work_unit, :start_time => Time.now-90.hours, :stop_time => Time.now-88.hours, :hours =>2, :user => admin, :notes => "Number4")
  end
  let! :user_work_units_out_of_range do
    FactoryGirl.create(:work_unit, :start_time => Time.now-100.hours, :stop_time => Time.now-98.hours, :hours =>2, :user => user, :notes => "Number5")
  end
  let! :user_work_units_in_range do
    FactoryGirl.create(:work_unit, :start_time => Time.now-2.hours, :stop_time => Time.now-1.hours, :hours =>1, :user => user, :notes => "Number6")
  end

  it "log in as a admin user" do
    visit root_path
    fill_in "Login", :with => admin.login
    fill_in "Password", :with => admin.password
    click_button 'Login'
  end

  it "visit the 'Calendar' page" do
    click_link 'Calendar'
  end

  it "should have Full Calendar loaded" do
    page.should have_selector(".fc-view-container")
  end

  it "should have my work unit events in the calendar" do
    page.should have_selector(".user-buttons")
    #check the box to load the feed
    click_button(admin.name)
    page.should have_content("#{admin_work_units_in_range.project.name} - #{admin_work_units_in_range.notes}")
    page.should_not have_content("#{user_work_units_in_range.project.name} - #{user_work_units_in_range.notes}")
    page.should_not have_content("#{admin_work_units_out_of_range.project.name} - #{admin_work_units_out_of_range.notes}")
    page.should_not have_content("#{user_work_units_out_of_range.project.name} - #{user_work_units_out_of_range.notes}")
 end

  it "should have user work unit events in the calendar" do
    page.should have_selector(".user-buttons")
    #check the box to load the feed
    click_button(user.name)
    page.should have_content("#{admin_work_units_in_range.project.name} - #{admin_work_units_in_range.notes}")
    page.should have_content("#{user_work_units_in_range.project.name} - #{user_work_units_in_range.notes}")
    page.should_not have_content("#{admin_work_units_out_of_range.project.name} - #{admin_work_units_out_of_range.notes}")
    page.should_not have_content("#{user_work_units_out_of_range.project.name} - #{user_work_units_out_of_range.notes}")
  end

  it "should go to work unit show page when item is clicked" do
    # puts page.body
    # require "pp"
    # pp WorkUnit.all.to_a
    click_on ("#{admin_work_units_in_range.project.name} - #{admin_work_units_in_range.notes}")
    page.should have_content("Editing Work Unit")
  end



end