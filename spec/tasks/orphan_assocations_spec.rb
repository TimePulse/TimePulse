require 'spec_helper'
require 'orphan_activity_associator'

describe OrphanActivityAssociator do
  before :each do
    Timecop.travel(Time.parse("6/2/2015 10am"))
  end

  let :earliest_time do
    Time.now - 24.hours
  end

  subject :associator do
    OrphanActivityAssociator.new(earliest_time)
  end

  after :each do
    Timecop.return
  end

  #activity without work unit
  #that is recent
  #user associated with orphan activies:
  #  clocked-in 15 after activity
  #  OR
  #  clocked-out 15 before
  #same project as activity

  let :project do
    FactoryGirl.create(:project)
  end

  let :other_project do
    FactoryGirl.create(:project)
  end

  let :start_time do
    Time.now - 3.hours
  end

  let :stop_time do
    Time.now - 2.hours
  end

  let :user do
    FactoryGirl.create(:user)
  end

  let! :work_unit do
    FactoryGirl.create(:work_unit,
                       :user => user,
                       :start_time => start_time,
                       :stop_time => stop_time,
                       :hours => 1.0,
                       :project => project)
  end

  describe "should associate an orphan activity that" do
    it "precedes a work unit with matching project by less than 15 minutes" do
      activity = FactoryGirl.create(:activity, :time => start_time - 14.minutes, :project => project, :user => user)
      associator.run
      expect(activity.reload.work_unit_id).to eql(work_unit.id)
    end

    it "follows a work unit with matching project by less than 15 minutes" do
      activity = FactoryGirl.create(:activity, :time => stop_time + 14.minutes, :project => project, :user => user)
      associator.run
      expect(activity.reload.work_unit_id).to eql(work_unit.id)
    end
  end

  describe "older data" do
    let :start_time do
      Time.now - 2.days
    end

    let :stop_time do
      Time.now - (2.days - 1.hour)
    end

    it "should not associate if the activity is too old" do
      activity = FactoryGirl.create(:activity, :time => stop_time + 14.minutes, :project => project, :user => user)
      associator.run
      expect(activity.reload.work_unit_id).to be_nil
    end
  end

  describe "should not associate an orphan activity" do
    it "precedes a work unit with matching project by more than 15 minutes" do
      activity = FactoryGirl.create(:activity, :time => start_time - 16.minutes, :project => project, :user => user)
      associator.run
      expect(activity.reload.work_unit_id).to be_nil
    end

    it "follows a work unit with matching project by more than 15 minutes" do
      activity = FactoryGirl.create(:activity, :time => stop_time + 16.minutes, :project => project, :user => user)
      associator.run
      expect(activity.reload.work_unit_id).to be_nil
    end

    it "to work unit with different project" do
      activity = FactoryGirl.create(:activity, :time => stop_time + 1.minutes, :project => other_project, :user => user)
      associator.run
      expect(activity.reload.work_unit_id).to be_nil
    end
  end

  it "should not associate an associated activity" do
    other_work_unit = FactoryGirl.create(:work_unit)
    activity = FactoryGirl.create(:activity, :time => stop_time + 1.minutes, :project => other_project, :work_unit => other_work_unit)
    associator.run
    expect(activity.reload.work_unit_id).to eql(other_work_unit.id)
  end

  it "should not associate to the work units of a different user" do
    other_user = FactoryGirl.create(:user)
    activity = FactoryGirl.create(:activity, :time => stop_time + 1.minutes, :project => project, :user => other_user)
    associator.run
    expect(activity.reload.work_unit_id).to be_nil
  end

end
