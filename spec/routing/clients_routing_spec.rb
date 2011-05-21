require 'spec_helper'

describe ClientsController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :get => "/clients" }.should route_to(:controller => "clients", :action => "index")
    end

    it "recognizes and generates #new" do
      { :get => "/clients/new" }.should route_to(:controller => "clients", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/clients/1" }.should route_to(:controller => "clients", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/clients/1/edit" }.should route_to(:controller => "clients", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/clients" }.should route_to(:controller => "clients", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "/clients/1" }.should route_to(:controller => "clients", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "/clients/1" }.should route_to(:controller => "clients", :action => "destroy", :id => "1") 
    end
  end
end
