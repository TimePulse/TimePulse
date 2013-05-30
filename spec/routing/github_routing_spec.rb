require 'spec_helper'

describe GithubController do
  describe "routing" do
    it "recognizes and generates #index" do
      { :post => "/github" }.should route_to(:controller => "github", :action => "create")
    end
  end
end
