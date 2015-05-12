require 'spec_helper'

describe WorkUnitQuery, :type => :query do

  before do
    Timecop.travel(Time.local(2015, 4, 27, 16, 0, 0))
  end

  before :each do
    @user_1 = FactoryGirl.create(:user, :name => 'Foo Bar 1')
    @user_2 = FactoryGirl.create(:user, :name => 'Foo Bar 2')
    @project_1 = FactoryGirl.create(:project)
    @project_2 = FactoryGirl.create(:project)

    @recent_work_unit_1 = FactoryGirl.create(:work_unit,
                           :hours => 5,
                           :user => @user_1,
                           :project => @project_1,
                           :start_time => Time.now - 2.weeks,
                           :stop_time => Time.now - 2.weeks + 6.hours)
		@recent_work_unit_2 = FactoryGirl.create(:work_unit,
                           :hours => 5,
                           :user => @user_1,
                           :project => @project_1,
                           :start_time => Time.now - 3.weeks,
													 :stop_time => Time.now - 3.weeks + 6.hours)
		@recent_work_unit_3 = FactoryGirl.create(:work_unit,
                           :hours => 5,
                           :user => @user_1,
                           :project => @project_1,
                           :start_time => Time.now - 3.weeks,
													 :stop_time => Time.now - 3.weeks + 6.hours,
                           :billable => false)
    @older_work_unit_1 = FactoryGirl.create(:work_unit,
													 :hours => 6,
													 :user => @user_2,
													 :project => @project_1,
													 :start_time => Time.now - 6.weeks,
													 :stop_time => Time.now - 6.weeks + 6.hours)
		@older_work_unit_2 = FactoryGirl.create(:work_unit,
													 :hours => 5,
													 :user => @user_2,
													 :project => @project_1,
													 :start_time => Time.now - 7.weeks,
													 :stop_time => Time.now - 7.weeks + 6.hours)
		@older_work_unit_3 = FactoryGirl.create(:work_unit,
													 :hours => 5,
													 :user => @user_2,
													 :project => @project_1,
													 :start_time => Time.now - 7.weeks,
													 :stop_time => Time.now - 7.weeks + 6.hours,
													 :billable => false)
    @billable_work_units_1 = WorkUnitQuery.new(@user_1,Time.now - 2.weeks,'billable')
    @billable_work_units_2 = WorkUnitQuery.new(@user_2,Time.now - 2.weeks,'billable')
    @unbillable_work_units_1 = WorkUnitQuery.new(@user_1,Time.now - 2.weeks,'unbillable')
    @unbillable_work_units_2 = WorkUnitQuery.new(@user_1,Time.now - 3.weeks,'unbillable')
    @total_work_units_1 = WorkUnitQuery.new(@user_1,Time.now - 3.weeks,'total')
	end

	it "should find older billable hours" do
		expect(WorkUnitQuery.new(@user_2,Time.now - 6.weeks,'billable').hours).to eq(6.0)
	end

  it "should find the recent billable hours" do
    expect(@billable_work_units_1.hours).to eq(5.0)
    expect(@billable_work_units_2.hours).to eq(0.0)
  end

  it "should find the recent unbillable hours" do
    expect(@unbillable_work_units_1.hours).to eq(0.0)
    expect(@unbillable_work_units_2.hours).to eq(5.0)
  end

  it "should find the recent total hours" do
    expect(@total_work_units_1.hours).to eq(10.0)
  end

  after do
    Timecop.return
  end
end