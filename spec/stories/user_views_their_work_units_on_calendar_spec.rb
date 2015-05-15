require 'spec_helper'

steps "see user work units on calendar", :type => :feature do
  let! :user do FactoryGirl.create(:user) end
  let! :user_work_units do FactoryGirl.create(:work_unit, :user => user, :hours => 4) end
  let! :non_user_work_units do FactoryGirl.create(:work_unit, :hours => 7) end
  let! :user_work_units_in_range do FactoryGirl.create(:work_unit, :start_time => Time.now-36.hours, :stop_time => Time.now-30.hours, :hours => 6, :user => user) end
  let! :user_work_units_out_of_range do FactoryGirl.create(:work_unit, :start_time => Time.now-90.hours, :stop_time => Time.now-60.hours, :hours =>30, :user => user) end

  it "log in as a regular user" do
    visit root_path
    fill_in "Login", :with => user.login
    fill_in "Password", :with => user.password
    click_button 'Login'
  end
=begin
  it "visit the 'Calendar' page" do
    click_link 'Calendar'
  end

  it "should have Full Calendar loaded" do
    page.should have_selector(".fc-view-container")
  end

  it "should have my work unit events in the calendar" do
    page.should have_selector(".work-unit", :text => user_work_units.project.name)
  end
=end
end