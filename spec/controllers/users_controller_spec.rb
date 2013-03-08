require "spec_helper"

describe UsersController do
  before do
    sign_out :user
  end

  describe "accessed by guest" do
    it "should forbid index" do
      get :index
      verify_authorization_unsuccessful
    end
  end

  describe "accessed by a normal user" do
    before do
      @user = authenticate(:user)
    end

    describe "get show" do
      it "should allow viewing own user" do 
        get :show, :id => @user.id
        verify_authorization_successful
      end

      it "should forbid viewing another user" do
        @other = Factory.create(:user)
        get :show, :id => @other.id
        verify_authorization_unsuccessful
      end
    end
    
    describe "get edit" do
      it "should allow editing own user" do
        get :edit, :id => @user.id
        verify_authorization_successful        
      end
    end
    
    describe "PUT update" do
      it "should be authorized" do
        put :update, :id => @user.id, :user => { :email => @user.email }
        verify_authorization_successful
      end
      it "should allow a user to update his own current task" do
        @task = Factory(:task)
        lambda do 
          put :update, :id => @user.id, :user => { :current_project_id => @task.id }
        end.should change{ @user.reload.current_project}.from(nil).to(@task)
      end
      
      it "should allow changing password" do
        lambda do 
          put :update, :id => @user.id, :user => { :password => "barfoo", :password_confirmation => "barfoo" }
        end.should change{ @user.reload.crypted_password }
        verify_authorization_successful
      end
    end
  end
  

  describe "accessed by admin" do

    before(:each) do
      @user = authenticate(:admin)
    end

    after(:each) do
      assigns[:user].destroy
    end

    it "should create users" do
      attributes =  Factory.attributes_for(:user)
      attributes.delete :groups
      post :create, :user => attributes
      
      response.should be_redirect
    end

    it "should assign users to the Registered Users group on creation" do
      attributes =  Factory.attributes_for(:user)
      attributes.delete :groups
      post :create, :user => attributes
      verify_authorization_successful
      user = assigns[:user]
      user.groups.should include(Group.find_by_name("Registered Users"))
    end
  end

end
