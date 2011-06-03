require 'spec_helper'

describe ProjectsController do
  before do
    @project = Factory(:project)
  end

  describe "accessed by a normal user" do
    before(:each) do          
      @user = authenticate(:user)
    end

    describe "GET index" do
      it "assigns all projects as @projects" do
        get :index
        controller.should be_forbidden
      end
    end

    describe "GET show" do
      it "assigns the requested project as @project" do
        get :show, :id => @project.id
        controller.should be_forbidden
      end
    end
      
    describe "forbidden actions" do
      it "should include GET edit" do
        get :edit, :id => @project.id
      end

      it "should include GET new" do
        get :new
      end

      it "should include PUT update" do
        put :update, :id => @project.id
      end

      it "should include POST create" do
        post :create
      end

      it "should include DELETE destroy" do
        delete :destroy, :id => @project.id
      end

      after do 
        controller.should be_forbidden
      end
    end
  end

  describe "accessed by and admin" do
    before do
      @user = authenticate(:admin)
    end
    
    describe "GET index" do
      it "assigns all projects as @projects" do
        get :index
        controller.should be_authorized
        assigns[:projects].should == Project.all
      end
    end

    describe "GET show" do
      it "assigns the requested project as @project" do
        get :show, :id => @project.id
        controller.should be_authorized
        assigns[:project].should ==  @project
      end
    end

    describe "GET new" do
      it "assigns a new project as @project" do
        get :new
        controller.should be_authorized
        assigns[:project].should be_a(Project)
        assigns[:project].should be_new_record
      end
    end

    describe "GET edit" do
      it "assigns the requested project as @project" do
        get :show, :id => @project.id
        controller.should be_authorized
        assigns[:project].should ==  @project
      end
    end

    describe "POST create" do

      describe "with valid params" do
        it "assigns a newly created project as @project" do
          post :create, :project => { :name => 'Cool Project' }
          controller.should be_authorized
          assigns[:project].should be_a(Project)
          assigns[:project].should_not be_new_record
        end

        it "redirects to the created project" do
          post :create, :project => { :name => 'Cool Project' }
          controller.should be_authorized
          response.should redirect_to(project_url(assigns[:project]))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved project as @project" do
          post :create, :project => { :name => '' }
          controller.should be_authorized
          assigns[:project].should be_a(Project)
          assigns[:project].should be_new_record
        end

        it "re-renders the 'new' template" do
          post :create, :project => { :name => '' }
          controller.should be_authorized
          response.should render_template('new')
        end
      end

    end

    describe "PUT update" do

      describe "with valid params" do
        it "updates the requested project" do
          lambda do 
            put :update, :id => @project.id, :project => {:name => 'new name'}
            controller.should be_authorized
          end.should change{ @project.reload.name }.to('new name')
        end

        it "assigns the requested project as @project" do
          put :update, :id => @project.id, :project => {:name => 'new name'}
          controller.should be_authorized
          assigns[:project].should == @project
        end

        it "redirects to the project" do
          put :update, :id => @project.id, :project => {:name => 'new name'}
          controller.should be_authorized
          response.should redirect_to(project_url(assigns[:project]))
        end
      end

      describe "with invalid params" do
        it "doesn't change the record" do
          lambda do
            put :update, :id => @project.id, :project => {:name => nil }
            controller.should be_authorized
          end.should_not change{ @project.reload }
        end

        it "assigns the project as @project" do
          put :update, :id => @project.id, :project => {:name => nil }
          controller.should be_authorized
          assigns[:project].should == @project
        end

        it "re-renders the 'edit' template" do
          put :update, :id => @project.id, :project => {:name => nil }
          controller.should be_authorized
          response.should render_template('edit')
        end
      end

    end

    describe "DELETE destroy" do
      it "reduces project count by one" do
        lambda do 
          delete :destroy, :id => @project.id
          controller.should be_authorized
        end.should change(Project, :count).by(-1)
      end

      it "should make the project unfindable in the DB" do
        delete :destroy, :id => @project.id
        controller.should be_authorized
        lambda{ Project.find(@project.id)}.should raise_error(ActiveRecord::RecordNotFound)
      end

      it "redirects to the projects list" do
        delete :destroy, :id => @project.id
        controller.should be_authorized
        response.should redirect_to(projects_url)
      end
    end

  end
end
