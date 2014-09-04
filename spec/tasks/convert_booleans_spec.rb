require 'spec_helper'
require 'rake'

describe 'db:convert_to_boolean namespace rake task', :type => :task do

  steps 'convert:boolean' do

    before do
      load File.expand_path("../../../lib/tasks/convert_booleans.rake", __FILE__)
      Rake::Task.define_task(:environment)
    end

    it 'should succeed' do
      Rake::Task["db:create_bool_columns"].reenable
      Rake::Task["db:create_bool_columns"].invoke
    end

    describe "projects" do
      let! :project do FactoryGirl.create(:project) end

      it 'should create new columns as "column_new"' do
        project.clockable_new.should be_nil
        project.billable_new.should be_nil
        project.flat_rate_new.should be_nil
        project.archived_new.should be_nil
      end
    end

    # it 'should create clients' do
    #   Client.count.should == 5
    #   Client.first.abbreviation.should == 'CL0'
    #   Client.last.abbreviation.should == 'CL4'
    # end

    # it 'should create projects' do
    #   Project.root.children.count.should == 5
    #   Project.root.children.each do |project|
    #     project.should_not be_clockable
    #   end
    # end

    # it 'should add default sub-projects to projects' do
    #   Project.root.children.each do |project|
    #     project.children.count.should == 3
    #   end
    # end

    # it 'should create work units, two for each user for each clockable project' do
    #   User.where(admin: false).each do |user|
    #     user.work_units.count.should == 30
    #   end
    # end

    # it 'should create rates' do
    #   User.where(admin: false).each do |user|
    #     user.rates.should_not be_empty
    #   end
    # end

    # it 'should create bills' do
    #   Bill.count.should == 5
    #   User.where(admin: false).each do |user|
    #     user.bills.size.should == 1
    #     user.bills.first.work_units.size.should == 5
    #   end
    # end

    # it 'should create invoices' do
    #   Invoice.count.should == 5
    #   Client.all.each do |client|
    #     client.invoices.size.should == 1
    #     client.invoices.first.work_units.size.should == 5
    #   end
    # end

    # it 'invoices should have invoice items' do
    #   Invoice.all.each do |invoice|
    #     invoice.invoice_items.size.should == 5
    #   end
    # end
  end

end
