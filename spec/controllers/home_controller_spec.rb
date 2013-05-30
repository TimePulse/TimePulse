require 'spec_helper'

describe HomeController do

  describe "logged in" do
    before :each do
      @user = authenticate(:user)
    end

    describe "GET 'index'" do
      it "should be successful" do
        get 'index'
      end

      it "should be authorized" do
        get 'index'
        verify_authorization_successful
      end
    end

    describe "with a current project selected" do
      before :each do
        @user.current_project = Factory(:project, :billable => true, :clockable => true)
        @user.save!
      end
      it "should find the current project" do
        get 'index'
        assigns[:current_project].should == @user.current_project
      end

      it "should find the completed work units" do
        @wu1 = Factory(:work_unit, :project => @user.current_project, :user => @user)
        @wu2 = Factory(:work_unit, :project => @user.current_project, :user => @user)
        get 'index'
        assigns[:work_units].should include(@wu1)
        assigns[:work_units].should include(@wu2)
      end

      it "should find the git commits" do
        @co1 = Factory(:activity, :source => "github", :project => @user.current_project, :user => @user)
        @co2 = Factory(:activity, :source => "github", :project => @user.current_project, :user => @user)
        get 'index'
        assigns[:commits].should include(@co1)
        assigns[:commits].should include(@co2)
      end

      it "should find the pivotal_updates" do
        @pu1 = Factory(:activity, :source => "pivotal", :project => @user.current_project, :user => @user)
        @pu2 = Factory(:activity, :source => "pivotal", :project => @user.current_project, :user => @user)
        get 'index'
        assigns[:pivotal_updates].should include(@pu1)
        assigns[:pivotal_updates].should include(@pu2)
      end

    end

  end

  describe "logged out" do
    before{ sign_out :user }
    it "is not authorizee" do
      get 'index'
      verify_authorization_unsuccessful
    end
  end
end
