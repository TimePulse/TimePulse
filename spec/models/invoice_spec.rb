# == Schema Information
#
# Table name: invoices
#
#  id               :integer(4)      not null, primary key
#  client_id        :integer(4)
#  notes            :text
#  created_at       :datetime
#  updated_at       :datetime
#  due_on           :date
#  paid_on          :date
#  reference_number :string(255)
#

require 'spec_helper'

describe Invoice do
  let :project do FactoryGirl.create(:project) end
  let :user do FactoryGirl.create(:user) end
  let! :rates_user do FactoryGirl.create(:rates_user, :rate => project.rates.last, :user => user) end

  before(:each) do
    @valid_attributes = {
      :due_on => Date.today,
      :paid_on => Date.today,
      :notes => "value for notes",
      :reference_number => "value for reference_number"
    }
  end

  it "should create a new instance given valid attributes" do
    invoice = Invoice.new(@valid_attributes)
    invoice.client = project.client
    invoice.save
  end


  describe "hours" do
    it "should give the sum of the hours in contained work units" do
      wus = [
        FactoryGirl.create(:work_unit, :user => user, :project => project, :hours => 1.0),
        FactoryGirl.create(:work_unit, :user => user, :project => project, :hours => 2.0),
        FactoryGirl.create(:work_unit, :user => user, :project => project, :hours => 3.0)
      ]
      FactoryGirl.create(:invoice, :client => project.client, :work_units => wus).hours.should == 6.0
    end
  end

  describe "overdue named scope" do
    it "should find a invoice due yesterday" do
      @wu = FactoryGirl.create(:invoice, :client => project.client, :due_on => Date.today - 1.day, :paid_on => nil)
      Invoice.overdue.should include(@wu)
    end
    it "should not find a invoice due today" do
      @wu = FactoryGirl.create(:invoice, :client => project.client, :due_on => Date.today, :paid_on => nil)
      Invoice.overdue.should_not include(@wu)
    end
    it "should not find a invoice due tomorrow" do
      @wu = FactoryGirl.create(:invoice, :client => project.client, :due_on => Date.today + 1.day, :paid_on => nil)
      Invoice.overdue.should_not include(@wu)
    end
    it "should not find a invoice due yesterday if it has been paid for" do
      @wu = FactoryGirl.create(:invoice, :client => project.client, :due_on => Date.today - 1.day, :paid_on => Date.today - 7.days)
      Invoice.overdue.should_not include(@wu)
    end
  end

  describe "paid named scope" do
    before(:each) do
      @paid_invoice = FactoryGirl.create(:invoice, :client => project.client, :due_on => Date.today - 1.day, :paid_on => Date.today - 6.days)
      @unpaid_invoice = FactoryGirl.create(:invoice, :client => project.client, :due_on => Date.today - 1.day, :paid_on => nil)
    end
    it "should find a paid invoice" do
      Invoice.paid.should include(@paid_invoice)
    end
    it "should not find an unpaid invoice" do
      Invoice.paid.should_not include(@unpaid_invoice)
    end
    it "should report it has been paid" do
      @paid_invoice.paid?.should be_true
    end
  end

  describe "unpaid named scope" do
    before(:each) do
      @paid_invoice = FactoryGirl.create(:invoice, :client => project.client, :due_on => Date.today - 1.day, :paid_on => Date.today - 6.days)
      @unpaid_invoice = FactoryGirl.create(:invoice, :client => project.client, :due_on => Date.today - 1.day, :paid_on => nil)
    end
    it "should not find a paid invoice" do
      Invoice.unpaid.should_not include(@paid_invoice)
    end
    it "should  find an unpaid invoice" do
      Invoice.unpaid.should include(@unpaid_invoice)
    end
    it "should report it has not been paid" do
      @unpaid_invoice.paid?.should be_false
    end
  end

  describe "work_unit_ids mass assignment" do
    it "should assign two work_units" do
      pending
      @proj = FactoryGirl.create(:project)
      @wu1 = FactoryGirl.create(:work_unit, :project => @proj)
      @wu2 = FactoryGirl.create(:work_unit, :project => @proj)
      @invoice = FactoryGirl.build(:invoice, :work_unit_ids => { @wu1.id => "1", @wu2.id => "1" } )
    end
  end

  describe "deleted invoice" do
    it "should mark associated work units as uninvoiced" do
      @wu = FactoryGirl.create(:work_unit, :user => user, :project => project)
      @invoice = FactoryGirl.create(:invoice, :client => project.client, :work_units => [ @wu ])
      @wu.invoice.should == @invoice
      @invoice.destroy
      @wu.invoice.should be_nil
    end
  end

  describe "invoice items" do
    it "should have an error if the client has no project" do
      new_client = FactoryGirl.create(:client, :name => 'New Client')
      invoice = FactoryGirl.build(:invoice, :client => new_client)
      invoice.save
      invoice.errors.size.should == 1
      invoice.errors[:invoice_items].first.should == 'This client has no projects.'
    end

    it "should have an error if a worker has no rate for the client" do
      new_user = FactoryGirl.create(:user, :name => 'New User')
      wu = FactoryGirl.create(:work_unit, :user => new_user, :project => project)
      invoice = FactoryGirl.build(:invoice, :client => project.client, :work_units => [ wu ])
      invoice.save
      invoice.errors.size.should == 1
      invoice.errors[:invoice_items].first.should == "There is no rate assigned to #{wu.user.name} for this client."
    end
  end

end
