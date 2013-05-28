require 'spec_helper'

describe PivotalController do
  describe "routing" do
    it "recognizes posts to #create" do
      { :post => "/pivotal" }.should route_to(:controller => "pivotal", :action => "create")
    end
  end
end
