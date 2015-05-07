require 'spec_helper'

describe WorkUnitQuery, :type => :query do

  before do
    Timecop.travel(Time.local(2015, 4, 27, 0, 0, 0))
  end

  before :each do
    @user_1 = FactoryGirl.create(:user, :name => 'Foo Bar 1')
    @user_2 = FactoryGirl.create(:user, :name => 'Foo Bar 2')
    @project_1 = FactoryGirl.create(:project)
    @project_2 = FactoryGirl.create(:project)

    @recent_work_units = [
        FactoryGirl.create(:work_unit,
                           :hours => 5,
                           :user => @user_1,
                           :project => @project_1,
                           :start_time => Time.now - 2.weeks),
        FactoryGirl.create(:work_unit,
                           :hours => 5,
                           :user => @user_1,
                           :project => @project_1,
                           :start_time => Time.now - 3.weeks),
        FactoryGirl.create(:work_unit,
                           :hours => 5,
                           :user => @user_1,
                           :project => @project_1,
                           :start_time => Time.now - 3.weeks,
                           :billable => false)
    ]
    @older_work_units = [
        FactoryGirl.create(:work_unit,
                           :hours => 5,
                           :user => @user_2,
                           :project => @project_1,
                           :start_time => Time.now - 6.weeks),
        FactoryGirl.create(:work_unit,
                           :hours => 5,
                           :user => @user_2,
                           :project => @project_1,
                           :start_time => Time.now - 7.weeks),
        FactoryGirl.create(:work_unit,
                           :hours => 5,
                           :user => @user_2,
                           :project => @project_1,
                           :start_time => Time.now - 7.weeks,
                           :billable => false)
    ]
    @billable_work_unit_1 = WorkUnitQuery.new(@user_1,Time.now,2,'billable')
    @billable_work_unit_2 = WorkUnitQuery.new(@user_2,Time.now,2,'billable')
    @unbillable_work_unit_1 = WorkUnitQuery.new(@user_1,Time.now,2,'unbillable')
    @unbillable_work_unit_2 = WorkUnitQuery.new(@user_1,Time.now,3,'unbillable')
    @total_work_unit_1 = WorkUnitQuery.new(@user_1,Time.now,3,'total')
  end

  it "should find the recent billable hours" do
    expect(@billable_work_unit_1.hours).to eq(5)
    expect(@billable_work_unit_2.hours).to eq(0)
  end

  it "should find the recent unbillable hours" do
    expect(@unbillable_work_unit_1.hours).to eq(0)
    expect(@unbillable_work_unit_2.hours).to eq(5)
  end

  it "should find the recent total hours" do
    expect(@total_work_unit_1.hours).to eq(10)
  end

  after do
    Timecop.return
  end
end