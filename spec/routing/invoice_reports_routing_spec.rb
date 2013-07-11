require 'spec_helper'

describe InvoiceReportsController do
  describe "routing" do
    it "recognizes and generates #show" do
      { :get => "/invoice_reports/1" }.should route_to(:controller => "invoice_reports", :action => "show", :id => "1")
    end
  end
end
