require 'spec_helper'

describe HomeController do
  before(:each) do
    authenticate(:user)    
  end

  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      
    end
  end
end
