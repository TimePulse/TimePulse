require 'spec_helper'

describe WorkUnitsController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :post => "/clock_in_on/1" }.should route_to(:controller => "clock_time", :action => "create", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/clock_out" }.should route_to(:controller => "clock_time", :action => "destroy") 
    end
  end
end
