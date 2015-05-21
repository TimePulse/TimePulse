require 'spec_helper'

describe UserApiTokensController do
  describe "routing" do
    it "recognizes and generates #update" do
      { :put => "/user_api_tokens/2" }.should route_to(:controller => "user_api_tokens", :action => "update", :id => "2")
    end
  end
end
