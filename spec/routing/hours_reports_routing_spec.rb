require 'spec_helper'

describe HoursReportsController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "/hours_reports" }.should route_to(:controller => "hours_reports", :action => "index")
    end
  end
end
