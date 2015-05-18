require 'spec_helper'

describe WorkUnitQuery, :type => :query do

  before do
    Timecop.travel(Time.local(2015, 4, 28, 16, 0, 0))
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
                           :stop_time => Time.now - 3.weeks + 5.hours)
    @recent_work_unit_3 = FactoryGirl.create(:work_unit,
                           :hours => 5,
                           :user => @user_1,
                           :project => @project_1,
                           :start_time => Time.now - 20.days,
                           :stop_time => Time.now - 20.days + 5.hours,
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
                           :start_time => DateTime.parse('Mar 12 15'),
                           :stop_time => DateTime.parse('Mar 12 15') + 6.hours,
                           :billable => false)

    @billable_work_units_1   = WorkUnitQuery.new(@user_1,'Apr 06 15','Apr 19 15','billable').hours
    @unbillable_work_units_1 = WorkUnitQuery.new(@user_1,'Apr 06 15','Apr 19 15','unbillable').hours
    @total_work_units_1      = WorkUnitQuery.new(@user_1,'Apr 06 15','Apr 19 15','total').hours
    @billable_work_units_2   = WorkUnitQuery.new(@user_2,'Mar 09 15','Mar 22 15','billable').hours
    @unbillable_work_units_2 = WorkUnitQuery.new(@user_2,'Mar 09 15','Mar 22 15','unbillable').hours
    @total_work_units_2      = WorkUnitQuery.new(@user_2,'Mar 09 15','Mar 22 15','total').hours
  end

  it 'should find recent hours' do
    expect(@billable_work_units_1[0][:hours]).to eq(5.0)
    expect(@billable_work_units_1[0][:sunday]).to eq('Apr 12 15')
    expect(@billable_work_units_1[1][:hours]).to eq(5.0)
    expect(@billable_work_units_1[1][:sunday]).to eq('Apr 19 15')

    expect(@unbillable_work_units_1[0][:hours]).to eq(5.0)
    expect(@unbillable_work_units_1[0][:sunday]).to eq('Apr 12 15')

    expect(@total_work_units_1[0][:hours]).to eq(10.0)
    expect(@total_work_units_1[0][:sunday]).to eq('Apr 12 15')
    expect(@total_work_units_1[1][:hours]).to eq(5.0)
    expect(@total_work_units_1[1][:sunday]).to eq('Apr 19 15')
  end

  it 'should find older hours' do
    expect(@billable_work_units_2[0][:hours]).to eq(5.0)
    expect(@billable_work_units_2[0][:sunday]).to eq('Mar 15 15')
    expect(@billable_work_units_2[1][:hours]).to eq(6.0)
    expect(@billable_work_units_2[1][:sunday]).to eq('Mar 22 15')

    expect(@unbillable_work_units_2[0][:hours]).to eq(5.0)
    expect(@unbillable_work_units_2[0][:sunday]).to eq('Mar 15 15')

    expect(@total_work_units_2[0][:hours]).to eq(10.0)
    expect(@total_work_units_2[0][:sunday]).to eq('Mar 15 15')
    expect(@total_work_units_2[1][:hours]).to eq(6.0)
    expect(@total_work_units_2[1][:sunday]).to eq('Mar 22 15')
  end

  after do
    Timecop.return
  end
end
