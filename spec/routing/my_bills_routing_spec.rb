require 'spec_helper'

describe MyBillsController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "/my_bills" }.should route_to(:controller => "my_bills", :action => "index")
    end

    it "recognizes and generates #show" do
      { :get => "/my_bills/1" }.should route_to(:controller => "my_bills", :action => "show", :bill_id => "1")
    end
  end
end
