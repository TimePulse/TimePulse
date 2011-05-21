require 'spec_helper'

describe BillsController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "/bills" }.should route_to(:controller => "bills", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/bills/new" }.should route_to(:controller => "bills", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/bills/1" }.should route_to(:controller => "bills", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/bills/1/edit" }.should route_to(:controller => "bills", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/bills" }.should route_to(:controller => "bills", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "/bills/1" }.should route_to(:controller => "bills", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "/bills/1" }.should route_to(:controller => "bills", :action => "destroy", :id => "1") 
    end
  end
end
