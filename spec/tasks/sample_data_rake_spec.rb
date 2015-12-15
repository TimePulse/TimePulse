require 'spec_helper'
require 'rake'

steps 'db:sample_data:load', :type => :task do

  before do
    load File.expand_path("../../../lib/tasks/sample_data.rake", __FILE__)
    Rake::Task.define_task(:environment)
  end

  it 'should succeed' do
    Rake::Task["db:sample_data:load"].reenable
    Rake::Task["db:sample_data:load"].invoke
  end

  it 'should have an admin user' do
    User.first.should be_admin
  end

  it 'should have a root project' do
    Project.first.should be_root
  end

  it 'should create users' do
    User.where(admin: false).size.should == 5
  end

  it 'should create each user\'s preferences' do
    User.all.each do |user|
      user.user_preferences.should_not be_nil
      user.user_preferences.recent_projects_count.should == 5
    end
  end

  it 'should create clients' do
    Client.count.should == 5
    Client.first.abbreviation.should == 'CL0'
    Client.last.abbreviation.should == 'CL4'
  end

  it 'should create projects' do
    Project.root.children.count.should == 5
    Project.root.children.each do |project|
      project.should_not be_clockable
    end
  end

  it 'should add default sub-projects to projects' do
    Project.root.children.each do |project|
      project.children.count.should == 3
    end
  end

  it 'should create work units for all non-admin users' do
    User.where(admin: false).each do |user|
      user.work_units.count.should > 100
    end
  end

  it 'should create activites for all work units' do
    WorkUnit.all.each do |wu|
      wu.notes.present?
    end
  end

  it 'should create rates' do
    User.where(admin: false).each do |user|
      user.rates.should_not be_empty
    end
  end

  it 'should not have a zero value for rate name' do
    User.where(admin: false).each do |user|
      user.rates[0].name.should_not == "Rate 0"
    end
  end

  it 'should have fifty for first rate amount' do
    User.where(admin: false).each_with_index do |user, i|
      user.rates.first.amount.to_i.should == 50 * (i + 1)
    end
  end

  it 'should create bills' do
    Bill.count.should == 5
    User.where(admin: false).each do |user|
      user.bills.size.should == 1
      user.bills.first.work_units.size.should == 5
    end
  end

  it 'should create invoices' do
    Invoice.count.should >= 1
    # TODO:  work unit projects are probabilistic now...

    #Client.all.each do |client|
    #client.invoices.size.should > 1
    #client.invoices.first.work_units.size.should > 5
    #end
  end

  it 'invoices should have invoice items' do
    Invoice.all.each do |invoice|
      invoice.invoice_items.size.should == 5
    end
  end

  skip do
    it 'should create activities' do
      pending 'until activities functionality is settled'
    end
  end

end

steps 'db:sample_data:clear', :type => :task do

  before do
    load File.expand_path("../../../lib/tasks/sample_data.rake", __FILE__)
    Rake::Task.define_task(:environment)
  end

  it 'should succeed' do
    Rake::Task["db:sample_data:clear"].reenable
    Rake::Task["db:sample_data:clear"].invoke
  end

  it 'should clear all tables' do
    User.count.should == 0
    UserPreferences.count.should == 0
    Client.count.should == 0
    Project.count.should == 0
    WorkUnit.count.should == 0
    Rate.count.should == 0
    RatesUser.count.should == 0
    Bill.count.should == 0
    Invoice.count.should == 0
    InvoiceItem.count.should == 0

    Activity.count.should == 0
  end

end
