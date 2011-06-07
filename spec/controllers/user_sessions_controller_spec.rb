require "spec_helper"

describe UserSessionsController do
  it "should be authorized" do
    LogicalAuthz::is_authorized?(:controller => "user_sessions", :action => "new").should be_true
  end
  
  describe "POST create" do
    before(:each) do
      @user = Factory.create(:user)
      logout
    end
             
    describe "with correct parameters" do
      before :each do
        post :create, :user_session => {:login => @user.login, :password => 'foobar'}
      end

      it "should be authorized" do
        controller.should be_authorized
      end

      it "should succeed" do
        assigns(:user_session).user.should == @user      
      end

      it "should redirect to the user dashboard" do
        response.should redirect_to root_url       
      end
    end

    it "should fail with incorrect parametets" do
      post :create, :user_session => {:login => @user.login, :password => 'wrong password'}
      assigns(:user_session).user.should be_nil
    end
  end
end
