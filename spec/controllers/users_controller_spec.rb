require "spec_helper"

describe UsersController do
  before do
    sign_out :user
    request.env['devise.mapping'] = Devise.mappings[:user]
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

    describe "get index" do
      it "should forbid index" do
        get :index
        verify_authorization_unsuccessful
      end
    end

    describe "get show" do
      it "should allow viewing own user" do
        get :show, :id => @user.id
        verify_authorization_successful
      end

      it "should forbid viewing another user" do
        @other = FactoryGirl.create(:user)
        get :show, :id => @other.id
        verify_authorization_unsuccessful
      end
    end

    describe " GET new" do
      it "should not be authorized" do
        get :new
        verify_authorization_unsuccessful
      end
    end

    describe "get edit" do
      it "should allow editing own user" do
        get :edit, :id => @user.id
        verify_authorization_successful
      end
    end

    describe "POST create" do
      it "should be forbidden" do
        attributes =  FactoryGirl.attributes_for(:user)
        post :create, :user => attributes
        verify_authorization_unsuccessful
      end
    end

    describe "PUT update" do
      let :base_params do
        { :password => '', :password_confirmation => '' }
      end

      let :task do
        FactoryGirl.create(:task)
      end
      it "should be authorized" do
        put :update, :id => @user.id, :user => base_params.merge({ :email => @user.email })
        verify_authorization_successful
      end

      it "should allow a user to update his own current task" do
        lambda do
          put :update, :id => @user.id, :user => base_params.merge({ :current_project_id => task.id })
        end.should change{ @user.reload.current_project}.from(nil).to(task)
      end

      it "should allow adding the github username" do
        lambda do
          put :update, :id => @user.id, :user => base_params.merge({ :github_user => 'whoohoo' })
        end.should change{ @user.reload.github_user }.to('whoohoo')
      end

      it "should allow changing password" do
        lambda do
          put :update, :id => @user.id, :user => base_params.merge({ :password => "barfoo", :password_confirmation => "barfoo" })
        end.should change{ @user.reload.encrypted_password }
        verify_authorization_successful
      end
    end

    it "cannot set itself to inactive" do
      put :update, :id => @user.id, :user => {:inactive => true}
      @user.reload.should_not be_inactive
    end

    it "cannot set another user to inactive" do
      @other_user = FactoryGirl.create(:user)
      put :update, :id => @other_user.id, :user => {:inactive => true}
      @other_user.reload.should_not be_inactive
    end

    it "cannot set itself as admin" do
      put :update, :id => @user.id, :user => {:admin => true}
      @user.reload.should_not be_admin
    end

    it "cannot set another user admin" do
      @other_user = FactoryGirl.create(:user)
      put :update, :id => @other_user.id, :user => {:admin => true}
      @other_user.reload.should_not be_admin
    end
  end


  describe "accessed by admin" do

    before(:each) do
      @user = authenticate(:admin)
    end

    describe "GET index" do
      it "should expose all users as @users" do
        @user = FactoryGirl.create(:user)

        get :index
        verify_authorization_successful
        assigns[:users].should include @user
      end
    end

    describe "GET new" do
      it "should allow new users" do
        get :new
        assigns[:user].should be_a(User)
        assigns[:user].should be_new_record
      end
    end

    describe "POST create" do
      it "should create users" do
        attributes =  FactoryGirl.attributes_for(:user)
        post :create, :user => attributes

        response.should be_redirect
      end

      it "renders new template on fail" do
        post :create, :user => { :name => nil }

        response.should render_template('new')
      end
    end

    it "should assign admin to false by default" do
      attributes =  FactoryGirl.attributes_for(:user)
      post :create, :user => attributes
      verify_authorization_successful
      user = assigns[:user]
      user.admin.should == false
    end

    it "can set the user to inactive" do
      @other_user = FactoryGirl.create(:user)
      put :update, :id => @other_user.id, :user => {:inactive => true}
      @other_user.reload.should be_inactive
    end

    it "can set the user as admin" do
      @other_user = FactoryGirl.create(:user)
      put :update, :id => @other_user.id, :user => {:admin => true}
      @other_user.reload.should be_admin
    end
  end
end
