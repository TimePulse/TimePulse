require 'spec_helper'

describe HomeController do

  describe "logged in" do
    before :each do
      authenticate(:user)
    end

    describe "GET 'index'" do
      it "should be successful" do
        get 'index'

      end

      it "should be authorized" do
        get 'index'
        controller.should be_authorized
      end
    end
  end

  describe "logged out" do
    before{ logout }
    it "is not authorizee" do
      get 'index'
      controller.should be_forbidden
    end
  end
end
