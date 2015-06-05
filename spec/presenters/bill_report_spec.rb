require 'spec_helper'

describe BillReport, :type => :presenter do
  let :billable_projects do
    FactoryGirl.create_list(:project, 3, :billable => true)
  end

  let :unbillable_projects do
    FactoryGirl.create_list(:project, 3, :billable => false)
  end

  let :unclockable_projects do
    FactoryGirl.create_list(:project, 2, :billable => false, :clockable => false)
  end

  let :clockable_projects do
    billable_projects + unbillable_projects
  end

  let :projects do
    (clockable_projects + unclockable_projects).shuffle
  end

  let :bill do
    FactoryGirl.create(:bill)
  end

  let :unbillable_wus do
    (1..17).zip(projects.cycle).map do |num, project|
      FactoryGirl.create(:work_unit, :billable => false, :hours => 1, :project => project, :bill => bill)
    end
  end

  let :billable_wus do
    (1..17).zip(projects.cycle).map do |num, project|
      FactoryGirl.create(:work_unit, :billable => true, :hours => 1, :project => project, :bill => bill)
    end
  end

  let :billable_clockable do
    billable_wus.find_all do |wu|
      wu.project.clockable?
    end
  end

  let! :work_units do
    unbillable_wus + billable_wus
  end

  let :total_billable_hours do
    billable_wus.inject(0) do |total, wu|
      total + wu.hours
    end
  end

  subject :bill_report do
    BillReport.new(bill)
  end

  it "should total hours consistently" do
    expect(bill_report.total_hours).to eql(billable_clockable.length * 1.0)
  end

  it "should have all the projects in #projects_and_hours" do
    expect(bill_report.projects_and_hours.length).to eql(clockable_projects.length)
  end

  it "should have all the billable WUs in #work_units_and_hours" do
    expect(bill_report.work_units_and_hours.length).to eql(billable_clockable.length)
    expect(bill_report.work_units_and_hours.map(&:notes).sort).to eql(billable_clockable.map(&:notes).sort)
  end

end
