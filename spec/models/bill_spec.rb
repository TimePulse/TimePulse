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
    @user = Factory(:user)
    @valid_attributes = {
      :due_on => Date.today,
      :paid_on => Date.today, 
      :user => @user,
      :notes => "value for notes"
    }
  end

  it "should not a new instance via massa-assignable attributes" do
    Bill.create!(@valid_attributes)
  end              

  describe "hours" do
    it "should give the sum of the hours in contained bills" do
      wus = [ 
        Factory(:work_unit, :hours => 1.0),
        Factory(:work_unit, :hours => 2.0),
        Factory(:work_unit, :hours => 3.0)                
      ]
      Factory(:bill, :work_units => wus).hours.should == 6.0      
    end
  end

  describe "overdue named scope" do
    it "should find a bill due yesterday" do
      @bill = Factory(:bill, :due_on => Date.today - 1.day)      
      Bill.overdue.should include(@bill)
    end
    it "should not find a bill due today" do
      @bill = Factory(:bill, :due_on => Date.today)      
      Bill.overdue.should_not include(@bill)      
    end
    it "should not find a bill due tomorrow" do
      @bill = Factory(:bill, :due_on => Date.today + 1.day)      
      Bill.overdue.should_not include(@bill)      
    end
    it "should not find a bill due yesterday if it was already paid" do
      @bill = Factory(:bill, :due_on => Date.today - 1.day, :paid_on => Date.today - 6.days)      
      Bill.overdue.should_not include(@bill)      
    end
  end
  
  describe "paid named scope" do
    before(:each) do
      @paid_bill = Factory(:bill, :due_on => Date.today - 1.day, :paid_on => Date.today - 6.days)      
      @unpaid_bill = Factory(:bill, :due_on => Date.today - 1.day, :paid_on => nil)      
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
      @paid_bill = Factory(:bill, :due_on => Date.today - 1.day, :paid_on => Date.today - 6.days)      
      @unpaid_bill = Factory(:bill, :due_on => Date.today - 1.day, :paid_on => nil)      
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
      @client = Factory(:client)  
      wus = [ 
        Factory(:work_unit, :hours => 1.0 )
      ]
      Factory(:bill, :work_units => wus).clients.should == [ wus.first.project.client ]     
    end

    describe "with multiple client projects involved" do
      before(:each) do
        @proj1 = Factory(:project)
        @proj2 = Factory(:project)
        @client1 = @proj1.client
        @client2 = @proj2.client          
        @wus = [ 
          Factory(:work_unit, :project => @proj1 ),
          Factory(:work_unit, :project => @proj1 ),
          Factory(:work_unit, :project => @proj2 ),          
        ]
        @bill = Factory(:bill, :work_units => @wus)
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

end
