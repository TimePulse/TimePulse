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
  before(:each) do
    @valid_attributes = {
      :due_on => Date.today,
      :paid_on => Date.today,
      :notes => "value for notes",
      :reference_number => "value for reference_number",
      :client => Factory(:client)
    }
  end

  it "should create a new instance given valid attributes" do
    Invoice.create!(@valid_attributes)
  end


  describe "hours" do
    it "should give the sum of the hours in contained work units" do
      wus = [
        Factory(:work_unit, :hours => 1.0),
        Factory(:work_unit, :hours => 2.0),
        Factory(:work_unit, :hours => 3.0)
      ]
      Factory(:invoice, :work_units => wus).hours.should == 6.0
    end
  end

  describe "overdue named scope" do
    it "should find a invoice due yesterday" do
      @wu = Factory(:invoice, :due_on => Date.today - 1.day, :paid_on => nil)
      Invoice.overdue.should include(@wu)
    end
    it "should not find a invoice due today" do
      @wu = Factory(:invoice, :due_on => Date.today, :paid_on => nil)
      Invoice.overdue.should_not include(@wu)
    end
    it "should not find a invoice due tomorrow" do
      @wu = Factory(:invoice, :due_on => Date.today + 1.day, :paid_on => nil)
      Invoice.overdue.should_not include(@wu)
    end
    it "should not find a invoice due yesterday if it has been paid for" do
      @wu = Factory(:invoice, :due_on => Date.today - 1.day, :paid_on => Date.today - 7.days)
      Invoice.overdue.should_not include(@wu)
    end
  end

  describe "paid named scope" do
    before(:each) do
      @paid_invoice = Factory(:invoice, :due_on => Date.today - 1.day, :paid_on => Date.today - 6.days)
      @unpaid_invoice = Factory(:invoice, :due_on => Date.today - 1.day, :paid_on => nil)
    end
    it "should find a paid invoice" do
      Invoice.paid.should include(@paid_invoice)
    end
    it "should not find an unpaid invoice" do
      Invoice.paid.should_not include(@unpaid_invoice)
    end
  end

  describe "unpaid named scope" do
    before(:each) do
      @paid_invoice = Factory(:invoice, :due_on => Date.today - 1.day, :paid_on => Date.today - 6.days)
      @unpaid_invoice = Factory(:invoice, :due_on => Date.today - 1.day, :paid_on => nil)
    end
    it "should not find a paid invoice" do
      Invoice.unpaid.should_not include(@paid_invoice)
    end
    it "should  find an unpaid invoice" do
      Invoice.unpaid.should include(@unpaid_invoice)
    end
  end

  describe "work_unit_ids mass assignment" do
    it "should assign two work_units" do
      pending
      @proj = Factory(:project)
      @wu1 = Factory(:work_unit, :project => @proj)
      @wu2 = Factory(:work_unit, :project => @proj)
      @invoice = Factory.build(:invoice, :work_unit_ids => { @wu1.id => "1", @wu2.id => "1" } )
    end
  end

  describe "deleted invoice" do
    it "should mark associated work units as uninvoiced" do
      @proj = Factory(:project)
      @wu = Factory(:work_unit, :project => @proj)
      @invoice = Factory(:invoice, :work_units => [ @wu ])
      @wu.invoice.should == @invoice
      @invoice.destroy
      @wu.invoice.should be_nil
    end
  end


end
