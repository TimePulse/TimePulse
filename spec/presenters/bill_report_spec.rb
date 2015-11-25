require 'spec_helper'

describe BillReport, :type => :presenter do
  describe "with a mix of project types" do
    let :billable_projects do
      FactoryGirl.create_list(:project, 3, :billable => true)
    end

    let :unbillable_projects do
      FactoryGirl.create_list(:project, 3, :billable => false)
    end

    let :clockable_projects do
      billable_projects + unbillable_projects
    end

    let :projects do
      clockable_projects.shuffle
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
  describe "with child projects" do

    let! :project do FactoryGirl.create(:project, :name => "Topmost") end
    let! :child_project do FactoryGirl.create(:project, :name => "Middle", :parent_id => project.id) end
    let! :grandchild_project do FactoryGirl.create(:project, :name => "Bottom", :parent_id => child_project.id) end
    let! :bill do FactoryGirl.create(:bill) end

    2.times do |idx|
      let! "project_work_unit_#{idx}" do
        FactoryGirl.create(:work_unit, :project => project, :hours => 2, :bill => bill)
      end
      let! "child_project_work_unit_#{idx}" do
        FactoryGirl.create(:work_unit, :project => child_project,  :hours => 4, :bill => bill)
      end
      let! "grandchild_project_work_unit_#{idx}" do
        FactoryGirl.create(:work_unit, :project => grandchild_project,  :hours => 6, :bill => bill)
      end
    end

    subject :bill_report do
      BillReport.new(bill)
    end

    it "should total hours consistently" do
      expect(bill_report.total_hours.to_f).to eql((2 * 2 + 2 * 4 + 2 * 6) * 1.0)
    end

    it "should not accumulate hours to parent projects" do
      expect(bill_report.projects_and_hours.length).to eql(3)
      expect(bill_report.projects_and_hours.map(&:hours).map(&:to_f)).to include(4.0, 8.0, 12.0)
    end

    it "should have all the billable WUs in #work_units_and_hours" do
      expect(bill_report.work_units_and_hours.length).to eql(6)
    end

  end

end
