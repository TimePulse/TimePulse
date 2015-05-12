require 'spec_helper'

steps "Admin views the hours reports", :type => :feature do

  before do
    Timecop.travel(Time.local(2015, 4, 27, 10, 0, 0))
  end

  let! :user_1 do FactoryGirl.create(:user, :name => "Foo Bar 1") end
  let! :user_2 do FactoryGirl.create(:user, :name => "Foo Bar 2") end
  let! :project_1 do FactoryGirl.create(:project) end
  let! :project_2 do FactoryGirl.create(:project) end
  let! :work_unit_0 do
    FactoryGirl.create(:work_unit, :hours => 10, :user => user_2, :project => project_2, :start_time => Time.now - 124.days, :stop_time => Time.now - 123.days, :billable => false)
  end
  let! :work_unit_1 do
    FactoryGirl.create(:work_unit, :hours => 9, :user => user_2, :project => project_2, :start_time => Time.now - 122.days, :stop_time => Time.now - 121.days)
  end
  let! :work_unit_2 do
    FactoryGirl.create(:work_unit, :hours => 8, :user => user_2, :project => project_2, :start_time => Time.now - 115.days, :stop_time => Time.now - 114.days, :billable => false)
  end
  let! :work_unit_3 do
    FactoryGirl.create(:work_unit, :hours => 7, :user => user_2, :project => project_2, :start_time => Time.now - 108.days, :stop_time => Time.now - 107.days)
  end
  let! :work_unit_4 do
    FactoryGirl.create(:work_unit, :hours => 6, :user => user_1, :project => project_1, :start_time => Time.now - 37.days, :stop_time => Time.now - 36.days)
  end
  let! :work_unit_5 do
    FactoryGirl.create(:work_unit, :hours => 5, :user => user_1, :project => project_1, :start_time => Time.now - 30.days, :stop_time => Time.now - 29.days, :billable => false)
  end
  let! :work_unit_6 do
    FactoryGirl.create(:work_unit, :hours => 4, :user => user_1, :project => project_1, :start_time => Time.now - 23.days, :stop_time => Time.now - 22.days, :billable => false)
  end
  let! :work_unit_7 do
    FactoryGirl.create(:work_unit, :hours => 3, :user => user_1, :project => project_1, :start_time => Time.now - 16.days, :stop_time => Time.now - 15.days)
  end
  let! :work_unit_8 do
    FactoryGirl.create(:work_unit, :hours => 2, :user => user_1, :project => project_1, :start_time => Time.now - 9.days, :stop_time => Time.now - 8.days)
  end
  let! :work_unit_9 do
    FactoryGirl.create(:work_unit, :hours => 1, :user => user_1, :project => project_1, :start_time => Time.now - 2.days, :stop_time => Time.now - 1.day)
  end
  let! :admin do FactoryGirl.create(:admin) end

  it 'should login as the admin' do
    visit root_path
    fill_in 'Login', :with => admin.login
    fill_in 'Password', :with => admin.password
    click_button 'Login'
  end

  it "should click the hours reports" do
    click_link 'Hours Reports'
  end

  it "should navigate to hours reports view" do
    current_path.should eq(hours_reports_path)
  end

  it "should show the last six Sundays as column headers" do
    expect(page).to have_content((Time.now.beginning_of_week - 1.day).strftime("%b %d %y"))
    expect(page).to have_content((Time.now.beginning_of_week - 8.days).strftime("%b %d %y"))
    expect(page).to have_content((Time.now.beginning_of_week - 15.days).strftime("%b %d %y"))
    expect(page).to have_content((Time.now.beginning_of_week - 22.days).strftime("%b %d %y"))
    expect(page).to have_content((Time.now.beginning_of_week - 29.days).strftime("%b %d %y"))
    expect(page).to have_content((Time.now.beginning_of_week - 36.days).strftime("%b %d %y"))
  end

  it "should show users with work units in the last six weeks as rows" do
    expect(page).to have_content("Foo Bar 1")
  end

  it "should not show users with work units not in the last six weeks" do
    expect(page).to_not have_content("Foo Bar 2")
  end

  it "should show billable, nonbillable, and total work units for one week ago" do
   expect(page).to have_content(user_1.work_units.where(:start_time => Time.now.beginning_of_week - 7.days..Time.now.beginning_of_week - 1.second).sum(:hours).to_s.to_f)
   expect(page).to have_content(user_1.work_units.where(:start_time => Time.now.beginning_of_week - 7.days..Time.now.beginning_of_week - 1.second).billable.sum(:hours).to_s.to_f)
   expect(page).to have_content(user_1.work_units.where(:start_time => Time.now.beginning_of_week - 7.days..Time.now.beginning_of_week - 1.second).unbillable.sum(:hours).to_s.to_f)
  end

  it "should show billable, nonbillable, and total work units for two weeks ago" do
   expect(page).to have_content(user_1.work_units.where(:start_time => Time.now.beginning_of_week - 1.second - 13.days..Time.now.beginning_of_week - 1.second - 7.days).sum(:hours).to_s.to_f)
   expect(page).to have_content(user_1.work_units.where(:start_time => Time.now.beginning_of_week - 1.second - 13.days..Time.now.beginning_of_week - 1.second - 7.days).billable.sum(:hours).to_s.to_f)
   expect(page).to have_content(user_1.work_units.where(:start_time => Time.now.beginning_of_week - 1.second - 13.days..Time.now.beginning_of_week - 1.second - 7.days).unbillable.sum(:hours).to_s.to_f)
  end

  it "should show billable, nonbillable, and total work units for three weeks ago" do
   expect(page).to have_content(user_1.work_units.where(:start_time => Time.now.beginning_of_week - 1.second - 20.days..Time.now.beginning_of_week - 1.second - 14.days).sum(:hours).to_s.to_f)
   expect(page).to have_content(user_1.work_units.where(:start_time => Time.now.beginning_of_week - 1.second - 20.days..Time.now.beginning_of_week - 1.second - 14.days).billable.sum(:hours).to_s.to_f)
   expect(page).to have_content(user_1.work_units.where(:start_time => Time.now.beginning_of_week - 1.second - 20.days..Time.now.beginning_of_week - 1.second - 14.days).unbillable.sum(:hours).to_s.to_f)
  end

  it "should show billable, nonbillable, and total work units for four weeks ago" do
   expect(page).to have_content(user_1.work_units.where(:start_time => Time.now.beginning_of_week - 1.second - 27.days..Time.now.beginning_of_week - 1.second - 21.days).sum(:hours).to_s.to_f)
   expect(page).to have_content(user_1.work_units.where(:start_time => Time.now.beginning_of_week - 1.second - 27.days..Time.now.beginning_of_week - 1.second - 21.days).billable.sum(:hours).to_s.to_f)
   expect(page).to have_content(user_1.work_units.where(:start_time => Time.now.beginning_of_week - 1.second - 27.days..Time.now.beginning_of_week - 1.second - 21.days).unbillable.sum(:hours).to_s.to_f)
  end

  it "should show billable, nonbillable, and total work units for five weeks ago" do
   expect(page).to have_content(user_1.work_units.where(:start_time => Time.now.beginning_of_week - 1.second - 34.days..Time.now.beginning_of_week - 1.second - 28.days).sum(:hours).to_s.to_f)
   expect(page).to have_content(user_1.work_units.where(:start_time => Time.now.beginning_of_week - 1.second - 34.days..Time.now.beginning_of_week - 1.second - 28.days).billable.sum(:hours).to_s.to_f)
   expect(page).to have_content(user_1.work_units.where(:start_time => Time.now.beginning_of_week - 1.second - 34.days..Time.now.beginning_of_week - 1.second - 28.days).unbillable.sum(:hours).to_s.to_f)
  end

  it "should show billable, nonbillable, and total work units for six weeks ago" do
   expect(page).to have_content(user_1.work_units.where(:start_time => Time.now.beginning_of_week - 1.second - 41.days..Time.now.beginning_of_week - 1.second - 35.days).sum(:hours).to_s.to_f)
   expect(page).to have_content(user_1.work_units.where(:start_time => Time.now.beginning_of_week - 1.second - 41.days..Time.now.beginning_of_week - 1.second - 35.days).billable.sum(:hours).to_s.to_f)
   expect(page).to have_content(user_1.work_units.where(:start_time => Time.now.beginning_of_week - 1.second - 41.days..Time.now.beginning_of_week - 1.second - 35.days).unbillable.sum(:hours).to_s.to_f)
  end

  it "should click the 'total' button" do
    find('#total-user-hours-btn').trigger('click')
  end

  it "should show only the total number of hours for each user" do
    expect(page).to have_content("1.0")
    expect(page).to have_content("2.0")
    expect(page).to have_content("3.0")
    expect(page).to have_content("4.0")
    expect(page).to have_content("5.0")
    expect(page).to have_content("6.0")
  end

  it "should click the 'billable' button" do
    find('#billable-user-hours-btn').trigger('click')
  end

  it "should show only the total number of billable hours for each user" do
    expect(page).to have_content("1.0")
    expect(page).to have_content("2.0")
    expect(page).to have_content("3.0")
    expect(page).to have_content("6.0")
    expect(page).to_not have_content("4.0")
    expect(page).to_not have_content("5.0")
  end

  it "should click the 'unbillable' button" do
    find('#unbillable-user-hours-btn').trigger('click')
  end

  it "should show only the total number of unbillable hours for each user" do
    expect(page).to have_content("4.0")
    expect(page).to have_content("5.0")
    expect(page).to have_content("0.0")
    expect(page).to_not have_content("1.0")
    expect(page).to_not have_content("2.0")
    expect(page).to_not have_content("3.0")
    expect(page).to_not have_content("6.0")
  end

  it "should click the 'billable' button" do
    find('#billable-user-hours-btn').trigger('click')
  end

  it "should show only the billable hours for each user" do
    expect(page).to have_content(user_1.work_units.where(:start_time => Time.now.beginning_of_week - 7.days..Time.now.beginning_of_week - 1.second).billable.sum(:hours).to_s.to_f)
    expect(page).to have_content(user_1.work_units.where(:start_time => Time.now.beginning_of_week - 1.second - 20.days..Time.now.beginning_of_week - 1.second - 14.days).billable.sum(:hours).to_s.to_f)
    expect(page).to_not have_content(user_1.work_units.where(:start_time => Time.now.beginning_of_week - 1.second - 27.days..Time.now.beginning_of_week - 1.second - 21.days).unbillable.sum(:hours).to_s.to_f)
    expect(page).to_not have_content(user_1.work_units.where(:start_time => Time.now.beginning_of_week - 1.second - 34.days..Time.now.beginning_of_week - 1.second - 28.days).sum(:hours).to_s.to_f)
  end

  it "should change the date range" do
    fill_in "start-datepicker", :with => "01/01/2015"
    fill_in "end-datepicker", :with => "01/15/2015"
    find('#datepicker-submit-btn').trigger('click')
  end

  it "should show the Sundays between the start and end dates as column headers" do
    expect(page).to have_content("Dec 28 14")
    expect(page).to have_content("Jan 04 15")
    expect(page).to have_content("Jan 11 15")
  end

  it "should show users with work units as rows" do
    expect(page).to have_content("Foo Bar 2")
  end

  it "should not show users with no work units" do
    expect(page).to_not have_content("Foo Bar 1")
  end

  it "should show total, billable, and unbillable work units for the last week" do
    expect(page).to have_content("19.0")
    expect(page).to have_content("10.0")
    expect(page).to have_content("9.0")
    expect(page).to have_content("8.0")
    expect(page).to have_content("7.0")
    expect(page).to have_content("0.0")
  end

  it "should click the 'total' button" do
    find('#total-user-hours-btn').trigger('click')
  end

  it "should show only the total number of hours for each user" do
    expect(page).to have_content("19.0")
    expect(page).to have_content("8.0")
    expect(page).to have_content("7.0")
    expect(page).to_not have_content("10.0")
    expect(page).to_not have_content("0.0")
  end

  it "should click the 'billable' button" do
    find('#billable-user-hours-btn').trigger('click')
  end

  it "should show only the total number of billable hours for each user" do
    expect(page).to     have_content("9.0")
    expect(page).to     have_content("7.0")
    expect(page).to     have_content("0.0")
    expect(page).to_not have_content("8.0")
    expect(page).to_not have_content("10.0")
  end

  it "should click the 'unbillable' button" do
    find('#unbillable-user-hours-btn').trigger('click')
  end

  it "should show only the total number of unbillable hours for each user" do
    expect(page).to_not have_content("9.0")
    expect(page).to_not have_content("7.0")
    expect(page).to     have_content("0.0")
    expect(page).to     have_content("8.0")
    expect(page).to     have_content("10.0")
  end

  it "should click the graph tab" do
    click_on "Graph"
  end

  it "should show the Sundays between the start and end dates as column headers" do
    expect(page).to have_content("Dec 28 14")
    expect(page).to have_content("Jan 04 15")
    expect(page).to have_content("Jan 11 15")
  end

  it "should show users with work units in the legend" do
    expect(page).to have_content("Foo Bar 2")
  end

  it "should not show users with no work units in the legend" do
    expect(page).to_not have_content("Foo Bar 1")
  end

  after do
    Timecop.return
  end
end
