require 'spec_helper'

describe WorkUnitsController do
  describe "routing" do
    it "doesnt route index" do
      { :get => '/work_units' }.should_not be_routable
    end

    it "recognizes and generates #new" do
      { :get => "/work_units/new" }.should route_to(:controller => "work_units", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/work_units/1" }.should route_to(:controller => "work_units", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/work_units/1/edit" }.should route_to(:controller => "work_units", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/work_units" }.should route_to(:controller => "work_units", :action => "create")
    end

    it "recognizes and generates #update" do
      { :put => "/work_units/1" }.should route_to(:controller => "work_units", :action => "update", :id => "1")
    end

    it "recognizes and generates #destroy" do
      { :delete => "/work_units/1" }.should route_to(:controller => "work_units", :action => "destroy", :id => "1")
    end
  end
end
