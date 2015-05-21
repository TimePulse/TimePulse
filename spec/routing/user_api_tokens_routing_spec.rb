require 'spec_helper'

describe UserApiTokensController do
  describe "routing" do
    it "recognizes and generates #update" do
      { :put => "/user_api_tokens" }.should route_to(:controller => "user_api_tokens", :action => "update")
    end
  end
end
