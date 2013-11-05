require 'spec_helper'

describe InvoiceReportsController do

  describe "as an admin" do
    before(:each) do
      authenticate(:admin)
    end

    ########################################################################################
    #                                      GET SHOW
    ########################################################################################
    describe "responding to GET show" do
      let :project do FactoryGirl.create(:project) end

      before :each  do
        @invoice = FactoryGirl.create(:invoice, :client => project.client)
        @client = @invoice.client
      end

      it "should expose the requested invoice as @invoice" do
        get :show, :id => @invoice.id
        assigns[:invoice].should == @invoice
      end

      it "should generate a report" do
        get :show, :id => @invoice.id
        assigns[:invoice_report].should_not be_nil
      end

      it "should be authorized" do
        get :show, :id => @invoice.id
        verify_authorization_successful
      end
    end
  end
end
