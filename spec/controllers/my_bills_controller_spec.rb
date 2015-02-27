require 'spec_helper'

describe MyBillsController do

  before(:each) do
    @bill = FactoryGirl.create(:bill, :due_on => Date.today + 1.week)
    @user = @bill.user
  end

  describe "as a normal user" do
    before(:each) do
      authenticate(@user)
    end

    ########################################################################################
    #                                      GET INDEX
    ########################################################################################
    describe "GET index" do
      before(:each) do
        @unpaid_bill_1 = FactoryGirl.create(:bill, :paid_on => nil, :due_on => Date.today + 1.month, :user => @user)
        @unpaid_bill_2 = FactoryGirl.create(:bill, :paid_on => nil, :due_on => Date.today + 3.weeks, :user => @user)
        @paid_bill_1 = FactoryGirl.create(:bill, :paid_on => Date.today - 1.day, :user => @user)
        @paid_bill_2 = FactoryGirl.create(:bill, :paid_on => Date.today - 2.day, :user => @user)
        @unpaid_bills = [
            @bill,
            @unpaid_bill_1,
            @unpaid_bill_2
        ].sort_by{|b| b.due_on}.reverse
        @paid_bills = [
          @paid_bill_1,
          @paid_bill_2
        ].sort_by{|b| b.paid_on}.reverse
      end
      it "should paginate all unpaid bills as @unpaid_bills" do
        get :index
        assigns[:unpaid_bills].should == @unpaid_bills.paginate
      end
      it "should paginate all paid bills as @paid_bills" do
        get :index
        assigns[:paid_bills].should == @paid_bills.paginate
      end
      it "should be authorized" do
        get :index
        verify_authorization_successful
      end
      it "should not display bills from other users" do
        bill_from_other_user = FactoryGirl.create(:bill, :due_on => Date.today + 1.week)
        get :index
        assigns[:unpaid_bills].should_not include(bill_from_other_user)
      end
    end

    ########################################################################################
    #                                      GET SHOW
    ########################################################################################
    describe "responding to GET show" do
      it "should expose the requested bill as @bill" do
        get :show, :bill_id => @bill.id
        assigns[:bill].should == @bill
      end
      it "should be authorized" do
        get :show, :bill_id => @bill.id
        verify_authorization_successful
      end
      it "should not allow access to bills from other users" do
        bill_from_other_user = FactoryGirl.create(:bill, :due_on => Date.today + 1.week)
        get :show, :bill_id => bill_from_other_user.id
        verify_authorization_unsuccessful
      end
    end

  end
end
