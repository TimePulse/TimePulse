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

    @billable_work_units_1   = WorkUnitQuery.new(@user_1,DateTime.parse('Apr 06 15'),DateTime.parse('Apr 19 15'),'billable').hours
    @unbillable_work_units_1 = WorkUnitQuery.new(@user_1,DateTime.parse('Apr 06 15'),DateTime.parse('Apr 19 15'),'unbillable').hours
    @total_work_units_1      = WorkUnitQuery.new(@user_1,DateTime.parse('Apr 06 15'),DateTime.parse('Apr 19 15'),'total').hours
    @billable_work_units_2   = WorkUnitQuery.new(@user_2,DateTime.parse('Mar 09 15'),DateTime.parse('Mar 22 15'),'billable').hours
    @unbillable_work_units_2 = WorkUnitQuery.new(@user_2,DateTime.parse('Mar 09 15'),DateTime.parse('Mar 22 15'),'unbillable').hours
    @total_work_units_2      = WorkUnitQuery.new(@user_2,DateTime.parse('Mar 09 15'),DateTime.parse('Mar 22 15'),'total').hours
  end

  it 'should find recent hours' do
    expect(@billable_work_units_1[0][:hours]).to eq(5.0)
    expect(@billable_work_units_1[0][:sunday].to_s).to eq(DateTime.parse('Apr 12 15').end_of_day.to_s)
    expect(@billable_work_units_1[1][:hours]).to eq(5.0)
    expect(@billable_work_units_1[1][:sunday].to_s).to eq(DateTime.parse('Apr 19 15').end_of_day.to_s)

    expect(@unbillable_work_units_1[0][:hours]).to eq(5.0)
    expect(@unbillable_work_units_1[0][:sunday].to_s).to eq(DateTime.parse('Apr 12 15').end_of_day.to_s)

    expect(@total_work_units_1[0][:hours]).to eq(10.0)
    expect(@total_work_units_1[0][:sunday].to_s).to eq(DateTime.parse('Apr 12 15').end_of_day.to_s)
    expect(@total_work_units_1[1][:hours]).to eq(5.0)
    expect(@total_work_units_1[1][:sunday].to_s).to eq(DateTime.parse('Apr 19 15').end_of_day.to_s)
  end

  it 'should find older hours' do
    expect(@billable_work_units_2[0][:hours]).to eq(5.0)
    expect(@billable_work_units_2[0][:sunday].to_s).to eq(DateTime.parse('Mar 15 15').end_of_day.to_s)
    expect(@billable_work_units_2[1][:hours]).to eq(6.0)
    expect(@billable_work_units_2[1][:sunday].to_s).to eq(DateTime.parse('Mar 22 15').end_of_day.to_s)

    expect(@unbillable_work_units_2[0][:hours]).to eq(5.0)
    expect(@unbillable_work_units_2[0][:sunday].to_s).to eq(DateTime.parse('Mar 15 15').end_of_day.to_s)

    expect(@total_work_units_2[0][:hours]).to eq(10.0)
    expect(@total_work_units_2[0][:sunday].to_s).to eq(DateTime.parse('Mar 15 15').end_of_day.to_s)
    expect(@total_work_units_2[1][:hours]).to eq(6.0)
    expect(@total_work_units_2[1][:sunday].to_s).to eq(DateTime.parse('Mar 22 15').end_of_day.to_s)
  end

  after do
    Timecop.return
  end
end
