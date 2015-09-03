require 'spec_helper'

steps 'Admin views the hours reports', :type => :feature do

  before do
    Timecop.travel(Time.local(2015, 4, 28, 10, 0, 0)) # Thursday Apr 28 15
  end

  let! :user_1 do FactoryGirl.create(:user, :name => 'Foo Bar 1') end
  let! :user_2 do FactoryGirl.create(:user, :name => 'Foo Bar 2') end
  let! :project_1 do FactoryGirl.create(:project) end
  let! :project_2 do FactoryGirl.create(:project) end
  let! :work_unit_0 do
    FactoryGirl.create(:work_unit, :hours => 10, :user => user_2, :project => project_2,
                       :start_time => 12.weeks.ago, :stop_time => 12.weeks.ago + 10.hours,
                       :billable => false)
                       # Feb 03 15
  end
  let! :work_unit_1 do
    FactoryGirl.create(:work_unit, :hours => 9, :user => user_2, :project => project_2,
                       :start_time => 11.weeks.ago, :stop_time => 11.weeks.ago + 10.hours)
                       # Feb 10 15
  end
  let! :work_unit_2 do
    FactoryGirl.create(:work_unit, :hours => 1, :user => user_2, :project => project_2,
                       :start_time => 12.weeks.ago, :stop_time => 12.weeks.ago + 10.hours)
                       # Feb 03 15
  end
  let! :work_unit_3 do
    FactoryGirl.create(:work_unit, :hours => 7, :user => user_1, :project => project_2,
                       :start_time => 6.weeks.ago, :stop_time => 6.weeks.ago + 10.hours)
                       # Mar 17 15
  end
  let! :work_unit_4 do
    FactoryGirl.create(:work_unit, :hours => 6, :user => user_1, :project => project_1,
                       :start_time => 5.weeks.ago, :stop_time => 5.weeks.ago + 10.hours)
                       # Mar 24 15
  end
  let! :work_unit_5 do
    FactoryGirl.create(:work_unit, :hours => 5, :user => user_1, :project => project_1,
                       :start_time => 4.weeks.ago, :stop_time => 4.weeks.ago + 10.hours,
                       :billable => false)
                       # Mar 31 15
  end
  let! :work_unit_6 do
    FactoryGirl.create(:work_unit, :hours => 4, :user => user_1, :project => project_1,
                       :start_time => 3.weeks.ago, :stop_time => 3.weeks.ago + 10.hours,
                       :billable => false)
                       # Apr 07 15
  end
  let! :work_unit_7 do
    FactoryGirl.create(:work_unit, :hours => 3, :user => user_1, :project => project_1,
                       :start_time => 2.weeks.ago, :stop_time => 2.weeks.ago + 10.hours)
                       # Apr 14 15
  end
  let! :work_unit_8 do
    FactoryGirl.create(:work_unit, :hours => 2, :user => user_1, :project => project_1,
                       :start_time => 1.week.ago, :stop_time => 1.week.ago + 10.hours)
                       # Apr 21 15
  end
  let! :work_unit_9 do
    FactoryGirl.create(:work_unit, :hours => 10, :user => user_1, :project => project_1,
                       :start_time => 4.days.ago, :stop_time => 4.days.ago + 10.hours,
                       :billable => false)
                       # Apr 24 15
  end
  let! :admin do FactoryGirl.create(:admin) end

  it 'should login as the admin' do
    visit root_path
    fill_in 'Login', :with => admin.login
    fill_in 'Password', :with => admin.password
    click_button 'Login'
  end

  it 'should click the hours reports' do
    click_link 'Reports'
    click_link 'Hours Reports'
  end

  it 'should navigate to hours reports view' do
    save_and_open_page
    current_path.should eq(hours_reports_path)
  end

  it 'should show the last six Sundays as column headers' do
    expect(page).to have_content('Mar 29 15')
    expect(page).to have_content('Apr 05 15')
    expect(page).to have_content('Apr 12 15')
    expect(page).to have_content('Apr 19 15')
    expect(page).to have_content('Apr 26 15')
    expect(page).to have_content('May 03 15')
  end

  it 'should show appropriate users as rows' do
    expect(page).to have_content('Foo Bar 1')
    expect(page).to_not have_content('Foo Bar 2')
  end

  it 'should show the user hours for the last six weeks' do
    expect(page).to have_content('6.0')
    expect(page).to have_content('5.0')
    expect(page).to have_content('4.0')
    expect(page).to have_content('3.0')
    expect(page).to have_content('2.0')
    expect(page).to have_content('10.0')
    expect(page).to have_content('12.0')
    expect(page).to_not have_content('7.0')
    expect(page).to_not have_content('9.0')
  end

  it "should click the 'total' button" do
    find('#total-user-hours-btn').trigger('click')
  end

  it 'should show only the total number of hours for each user' do
    expect(page).to have_content('6.0')
    expect(page).to have_content('5.0')
    expect(page).to have_content('4.0')
    expect(page).to have_content('3.0')
    expect(page).to have_content('12.0')
    expect(page).to_not have_content('10.0')
  end

  it "should click the 'billable' button" do
    find('#billable-user-hours-btn').trigger('click')
  end

  it 'should show only the total number of billable hours for each user' do
    expect(page).to have_content('6.0')
    expect(page).to have_content('3.0')
    expect(page).to_not have_content('5.0')
    expect(page).to_not have_content('4.0')
    expect(page).to_not have_content('10.0')
  end

  it "should click the 'unbillable' button" do
    find('#unbillable-user-hours-btn').trigger('click')
  end

  it 'should show only the total number of unbillable hours for each user' do
    expect(page).to have_content('5.0')
    expect(page).to have_content('4.0')
    expect(page).to have_content('10.0')
    expect(page).to_not have_content('12.0')
    expect(page).to_not have_content('6.0')
  end

  it 'should change the date range' do
    fill_in 'start-datepicker', :with => '02/04/2015'
    fill_in 'end-datepicker', :with => '02/18/2015'
    find('#datepicker-submit-btn').trigger('click')
  end

  it 'should show the Sundays between the start and end dates as column headers' do
    expect(page).to have_content('Feb 08 15')
    expect(page).to have_content('Feb 15 15')
    expect(page).to have_content('Feb 22 15')
  end

  it 'should show users with work units as rows' do
    expect(page).to have_content('Foo Bar 2')
    expect(page).to_not have_content('Foo Bar 1')
  end

  it 'should show the total, billable, unbillable hours for the new time period' do
    expect(page).to have_content('10.0')
    expect(page).to have_content('1.0')
    expect(page).to have_content('11.0')
    expect(page).to have_content('9.0')
    expect(page).to_not have_content('3.0')
    expect(page).to_not have_content('4.0')
  end

  it "should click the 'total' button" do
    find('#total-user-hours-btn').trigger('click')
  end

  it 'should show only the total number of hours for each user' do
    expect(page).to have_content('11.0')
    expect(page).to have_content('9.0')
    expect(page).to_not have_content('10.0')
  end

  it "should click the 'billable' button" do
    find('#billable-user-hours-btn').trigger('click')
  end

  it 'should show only the total number of billable hours for each user' do
    expect(page).to have_content('9.0')
    expect(page).to have_content('1.0')
    expect(page).to_not have_content('10.0')
  end

  it "should click the 'unbillable' button" do
    find('#unbillable-user-hours-btn').trigger('click')
  end

  it 'should show only the total number of unbillable hours for each user' do
    expect(page).to have_content('10.0')
    expect(page).to_not have_content('9.0')
  end

  it 'should click the graph tab' do
    click_on 'Graph'
  end

  it 'should show the Sundays between the start and end dates as x-axis labels' do
    expect(page).to have_content('Feb 08 15')
    expect(page).to have_content('Feb 15 15')
    # expect(page).to have_content('Feb 22 15')
  end

  it 'should show users with work units in the legend' do
    expect(page).to have_content('Foo Bar 2')
    expect(page).to_not have_content('Foo Bar 1')
  end

  it 'should change the date range' do
    fill_in 'start-datepicker', :with => '02/04/2015'
    fill_in 'end-datepicker', :with => '04/26/2015'
    find('#datepicker-submit-btn').trigger('click')
  end

  it 'should show users with work units in the legend' do
    expect(page).to have_content('Foo Bar 1')
    expect(page).to have_content('Foo Bar 2')
  end

  it 'should show the Sundays between the start and end dates as x-axis labels' do
    expect(page).to have_content('Feb 08 15')
    expect(page).to have_content('Feb 15 15')
    expect(page).to have_content('Feb 22 15')
    expect(page).to have_content('Mar 01 15')
    expect(page).to have_content('Mar 08 15')
    expect(page).to have_content('Mar 15 15')
    expect(page).to have_content('Mar 22 15')
    expect(page).to have_content('Mar 29 15')
    expect(page).to have_content('Apr 05 15')
    expect(page).to have_content('Apr 12 15')
    expect(page).to have_content('Apr 19 15')
    expect(page).to have_content('Apr 26 15')
  end

  after do
    Timecop.return
  end
end
