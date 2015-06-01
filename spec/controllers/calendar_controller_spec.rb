require 'spec_helper'

describe CalendarsController do
  describe "GET Index" do
    describe "While logged in" do
      let! :user do FactoryGirl.create(:user) end
      let! :admin do FactoryGirl.create(:admin) end
      describe "User Login" do
        before :each do
           authenticate(user)
           get :index
        end
        it "assigns @users to only include current_user" do
           assigns[:users].should include(user)
           assigns[:users].should_not include(admin)
        end
      end

      describe "Admin Login" do
        before :each do
           authenticate(admin)
           get :index
        end
        it "assigns @users to include admin and user" do
           assigns[:users].should include(user)
           assigns[:users].should include(admin)
        end
      end
    end

    describe "While not logged in" do
      it "should redirect to the login page" do
        get :index
        verify_authorization_unsuccessful
      end

    end
  end
end
