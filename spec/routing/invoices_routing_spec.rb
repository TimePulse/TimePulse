require 'spec_helper'

describe InvoicesController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "/invoices" }.should route_to(:controller => "invoices", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/invoices/new" }.should route_to(:controller => "invoices", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/invoices/1" }.should route_to(:controller => "invoices", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/invoices/1/edit" }.should route_to(:controller => "invoices", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/invoices" }.should route_to(:controller => "invoices", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "/invoices/1" }.should route_to(:controller => "invoices", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "/invoices/1" }.should route_to(:controller => "invoices", :action => "destroy", :id => "1") 
    end
  end
end
