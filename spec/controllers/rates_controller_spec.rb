require 'spec_helper'

describe RatesController do
  before do
    @rate = Factory(:rate)
    @user = Factory(:user)
  end

  describe "accessed by an admin" do
    before do
      authenticate(:admin)
    end

    describe "PUT update" do

      describe "with valid params" do
        it "adds the requested user" do
          lambda do
            put :update, :id => @rate.id, :users => [@user.id]
            verify_authorization_successful
          end.should change{ @rate.reload.users.size }.to(1)
        end

        it "removes unselected user" do
          @rate.users << @user
          lambda do
            put :update, :id => @rate.id, :users => nil
            verify_authorization_successful
          end.should_not change{ @rate.reload }
        end

        it "redirects to Project#show" do
          put :update, :id => @rate.id, :add_user => @user.id
          verify_authorization_successful
          response.should redirect_to(project_url(@rate.project))
        end
      end
    end
  end
end
