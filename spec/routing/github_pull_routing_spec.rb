require 'spec_helper'

describe GithubPullController do
  describe "routing" do
    it "recognizes and generates #create" do
      { :post => "/projects/1/github_pull" }.should route_to(:controller => "github_pull", :action => "create", :project_id => "1") 
    end
  end
end
