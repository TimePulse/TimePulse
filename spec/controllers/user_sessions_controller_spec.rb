require "spec_helper"

describe UserSessionsController do
  it "should be authorized" do
    LogicalAuthz::is_authorized?(:controller => "user_sessions", :action => "new").should be_true
  end
  
  describe "POST create" do
    before(:each) do
      @user = Factory.create(:user)
    end
             
    describe "with correct parameters" do
      it "should succeed" do
        post :create, :user_session => {:login => @user.login, :password => 'foobar'}
        assigns(:user_session).user.should == @user      
      end
      it "should redirect to the user dashboard" do
        post :create, :user_session => {:login => @user.login, :password => 'foobar'}
        response.should redirect_to root_url       
      end
    end

    it "should fail with incorrect parametets" do
      post :create, :user_session => {:login => @user.login, :password => 'wrong password'}
      assigns(:user_session).user.should be_nil
    end
  end
end
