require 'spec_helper'

steps "Admin views the hours reports", :type => :feature do

	before do
		Timecop.travel(Time.local(2015, 4, 27, 10, 0, 0))
	end

  let! :user_1 do FactoryGirl.create(:user, :name => "Foo Bar 1") end
  let! :user_2 do FactoryGirl.create(:user, :name => "Foo Bar 2") end
  let! :project_1 do FactoryGirl.create(:project) end
  let! :project_2 do FactoryGirl.create(:project) end
  let! :work_unit_1 do
    FactoryGirl.create(:work_unit, :hours => 5, :user => user_1, :project => project_1, :start_time => Time.now - 2.weeks, :stop_time => Time.now - 10.days)
  end
  let! :work_unit_2 do
    FactoryGirl.create(:work_unit, :hours => 5, :user => user_2, :project => project_2, :start_time => Time.now - 8.weeks, :stop_time => Time.now - 7.weeks)
	end
	let! :work_unit_3 do
		FactoryGirl.create(:work_unit, :hours => 5, :user => user_1, :project => project_1, :start_time => Time.now - 3.weeks, :stop_time => Time.now - 20.days)
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
    page.should have_content((Time.now.beginning_of_week - 1.day).strftime("%b %d %y"))
    page.should have_content((Time.now.beginning_of_week - 8.days).strftime("%b %d %y"))
    page.should have_content((Time.now.beginning_of_week - 15.days).strftime("%b %d %y"))
    page.should have_content((Time.now.beginning_of_week - 22.days).strftime("%b %d %y"))
    page.should have_content((Time.now.beginning_of_week - 29.days).strftime("%b %d %y"))
    page.should have_content((Time.now.beginning_of_week - 36.days).strftime("%b %d %y"))
  end

  it "should show users with work units in the last six weeks as rows" do
    page.should have_content("Foo Bar 1")
  end

  it "should not show users with work units not in the last six weeks" do
    page.should_not have_content("Foo Bar 2")
  end

  it "should show billable, nonbillable, and total work units for one week ago" do
    page.should have_content(user_1.work_units.where(:start_time => Time.now.beginning_of_week - 1.second - 6.days..Time.now.beginning_of_week - 1.second).sum(:hours).to_s.to_f)
    page.should have_content(user_1.work_units.where(:start_time => Time.now.beginning_of_week - 1.second - 6.days..Time.now.beginning_of_week - 1.second).billable.sum(:hours).to_s.to_f)
    page.should have_content(user_1.work_units.where(:start_time => Time.now.beginning_of_week - 1.second - 6.days..Time.now.beginning_of_week - 1.second).unbillable.sum(:hours).to_s.to_f)
	end

	it "should show billable, nonbillable, and total work units for two weeks ago" do
		page.should have_content(user_1.work_units.where(:start_time => Time.now.beginning_of_week - 1.second - 13.days..Time.now.beginning_of_week - 1.second - 7.days).sum(:hours).to_s.to_f)
		page.should have_content(user_1.work_units.where(:start_time => Time.now.beginning_of_week - 1.second - 13.days..Time.now.beginning_of_week - 1.second - 7.days).billable.sum(:hours).to_s.to_f)
		page.should have_content(user_1.work_units.where(:start_time => Time.now.beginning_of_week - 1.second - 13.days..Time.now.beginning_of_week - 1.second - 7.days).unbillable.sum(:hours).to_s.to_f)
	end

	it "should show billable, nonbillable, and total work units for three weeks ago" do
		page.should have_content(user_1.work_units.where(:start_time => Time.now.beginning_of_week - 1.second - 20.days..Time.now.beginning_of_week - 1.second - 14.days).sum(:hours).to_s.to_f)
		page.should have_content(user_1.work_units.where(:start_time => Time.now.beginning_of_week - 1.second - 20.days..Time.now.beginning_of_week - 1.second - 14.days).billable.sum(:hours).to_s.to_f)
		page.should have_content(user_1.work_units.where(:start_time => Time.now.beginning_of_week - 1.second - 20.days..Time.now.beginning_of_week - 1.second - 14.days).unbillable.sum(:hours).to_s.to_f)
	end

	it "should show billable, nonbillable, and total work units for four weeks ago" do
		page.should have_content(user_1.work_units.where(:start_time => Time.now.beginning_of_week - 1.second - 27.days..Time.now.beginning_of_week - 1.second - 21.days).sum(:hours).to_s.to_f)
		page.should have_content(user_1.work_units.where(:start_time => Time.now.beginning_of_week - 1.second - 27.days..Time.now.beginning_of_week - 1.second - 21.days).billable.sum(:hours).to_s.to_f)
		page.should have_content(user_1.work_units.where(:start_time => Time.now.beginning_of_week - 1.second - 27.days..Time.now.beginning_of_week - 1.second - 21.days).unbillable.sum(:hours).to_s.to_f)
	end

	it "should show billable, nonbillable, and total work units for five weeks ago" do
		page.should have_content(user_1.work_units.where(:start_time => Time.now.beginning_of_week - 1.second - 34.days..Time.now.beginning_of_week - 1.second - 28.days).sum(:hours).to_s.to_f)
		page.should have_content(user_1.work_units.where(:start_time => Time.now.beginning_of_week - 1.second - 34.days..Time.now.beginning_of_week - 1.second - 28.days).billable.sum(:hours).to_s.to_f)
		page.should have_content(user_1.work_units.where(:start_time => Time.now.beginning_of_week - 1.second - 34.days..Time.now.beginning_of_week - 1.second - 28.days).unbillable.sum(:hours).to_s.to_f)
	end

	it "should show billable, nonbillable, and total work units for six weeks ago" do
		page.should have_content(user_1.work_units.where(:start_time => Time.now.beginning_of_week - 1.second - 41.days..Time.now.beginning_of_week - 1.second - 35.days).sum(:hours).to_s.to_f)
		page.should have_content(user_1.work_units.where(:start_time => Time.now.beginning_of_week - 1.second - 41.days..Time.now.beginning_of_week - 1.second - 35.days).billable.sum(:hours).to_s.to_f)
		page.should have_content(user_1.work_units.where(:start_time => Time.now.beginning_of_week - 1.second - 41.days..Time.now.beginning_of_week - 1.second - 35.days).unbillable.sum(:hours).to_s.to_f)
	end

	after do
		Timecop.return
	end
end
