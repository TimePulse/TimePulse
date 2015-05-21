require 'spec_helper'

describe UserApiTokensController do
  describe "PATCH Update" do
    describe "While logged in" do
      let! :user do FactoryGirl.create(:user) end
      describe "User Login" do
        before :each do
           authenticate(user)
           patch :update
        end
        it "should generate a unencrypted token" do
        end
        it "should generate an encrypted token" do
        end

        it "should save the encrypted token to DB" do
        end

        it "should return the "

      end
    end

    describe "While not logged in" do
      it "should redirect to the login page" do
        patch :update
        verify_authorization_unsuccessful
      end
    end
  end
end