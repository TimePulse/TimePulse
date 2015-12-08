require 'spec_helper'

describe UserApiTokensController do
  describe "PUT Update" do
    describe "While logged in" do
      let! :user do FactoryGirl.create(:user) end
      describe "User Login" do
        before :each do
           authenticate(user)
           put :update, :format => :json

        end
        it "should generate a unencrypted token" do
          assigns[:unencrypted_token].should be_a(String)
        end
        it "should generate an encrypted token" do
          assigns[:encrypted_token].should be_a(String)
        end

        it "should save the encrypted token to DB" do
          user.reload
          user.encrypted_token.should == assigns[:encrypted_token]
        end

        it "should respond with success for the token request" do
          response.should be_success
        end
      end
    end

    describe "While not logged in" do
      it "should redirect to the login page" do
        put :update, :format => :json
        verify_authorization_unsuccessful
      end
    end
  end
end
