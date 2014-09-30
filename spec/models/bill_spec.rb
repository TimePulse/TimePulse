# == Schema Information
#
# Table name: bills
#
#  id               :integer(4)      not null, primary key
#  user_id          :integer(4)
#  notes            :text
#  created_at       :datetime
#  updated_at       :datetime
#  due_on           :date
#  paid_on          :date
#  reference_number :string(255)
#

require 'spec_helper'

describe Bill do
  before(:each) do
    @user = FactoryGirl.create(:user)
    @valid_attributes = {
      :due_on => Date.today,
      :paid_on => Date.today,
      :notes => "value for notes"
    }
  end

  it "should not a new instance via massa-assignable attributes" do
    bill = Bill.new(@valid_attributes)
    bill.user = @user
    bill.save
  end

  describe "hours" do
    it "should give the sum of the hours in contained bills" do
      wus = [
        FactoryGirl.create(:work_unit, :hours => 1.0),
        FactoryGirl.create(:work_unit, :hours => 2.0),
        FactoryGirl.create(:work_unit, :hours => 3.0)
      ]
      FactoryGirl.create(:bill, :work_units => wus).hours.should == 6.0
    end
  end

  describe "overdue named scope" do
    it "should find a bill due yesterday" do
      @bill = FactoryGirl.create(:bill, :due_on => Date.today - 1.day)
      Bill.overdue.should include(@bill)
    end
    it "should not find a bill due today" do
      @bill = FactoryGirl.create(:bill, :due_on => Date.today)
      Bill.overdue.should_not include(@bill)
    end
    it "should not find a bill due tomorrow" do
      @bill = FactoryGirl.create(:bill, :due_on => Date.today + 1.day)
      Bill.overdue.should_not include(@bill)
    end
    it "should not find a bill due yesterday if it was already paid" do
      @bill = FactoryGirl.create(:bill, :due_on => Date.today - 1.day, :paid_on => Date.today - 6.days)
      Bill.overdue.should_not include(@bill)
    end
  end

  describe "paid named scope" do
    before(:each) do
      @paid_bill = FactoryGirl.create(:bill, :due_on => Date.today - 1.day, :paid_on => Date.today - 6.days)
      @unpaid_bill = FactoryGirl.create(:bill, :due_on => Date.today - 1.day, :paid_on => nil)
    end
    it "should find a paid bill" do
      Bill.paid.should include(@paid_bill)
    end
    it "should not find an unpaid bill" do
      Bill.paid.should_not include(@unpaid_bill)
    end
  end
  describe "unpaid named scope" do
    before(:each) do
      @paid_bill = FactoryGirl.create(:bill, :due_on => Date.today - 1.day, :paid_on => Date.today - 6.days)
      @unpaid_bill = FactoryGirl.create(:bill, :due_on => Date.today - 1.day, :paid_on => nil)
    end
    it "should not find a paid bill" do
      Bill.unpaid.should_not include(@paid_bill)
    end
    it "should  find an unpaid bill" do
      Bill.unpaid.should include(@unpaid_bill)
    end
  end

  describe "clients" do
    it "should return an array containing the single client for associated work units" do
      @client = FactoryGirl.create(:client)
      wus = [
        FactoryGirl.create(:work_unit, :hours => 1.0 )
      ]
      FactoryGirl.create(:bill, :work_units => wus).clients.should == [ wus.first.project.client ]
    end

    describe "with multiple client projects involved" do
      before(:each) do
        @proj1 = FactoryGirl.create(:project)
        @proj2 = FactoryGirl.create(:project)
        @client1 = @proj1.client
        @client2 = @proj2.client
        @wus = [
          FactoryGirl.create(:work_unit, :project => @proj1 ),
          FactoryGirl.create(:work_unit, :project => @proj1 ),
          FactoryGirl.create(:work_unit, :project => @proj2 ),
        ]
        @bill = FactoryGirl.create(:bill, :work_units => @wus)
      end
      it "should return an array containing both associated clients" do
        @bill.clients.should include(@client1)
        @bill.clients.should include(@client2)
      end
      it "should return an array with only the right number of clients" do
        @bill.clients.should have(2).clients
      end
    end
  end

  describe "dissociate_work_units" do
    before(:each) do
      @wus = [
        FactoryGirl.create(:work_unit),
        FactoryGirl.create(:work_unit),
        FactoryGirl.create(:work_unit),
      ]
      @bill = FactoryGirl.create(:bill, :work_units => @wus)

      @bill.send(:dissociate_work_units)
    end

    it "should set all work units' bill to nil" do
      @wus.map(&:bill).should eq([nil,nil,nil])
    end
  end

end
