require 'spec_helper'

describe ProjectReportsController do
  before do
    @project = FactoryGirl.create(:project)
  end

  describe "GET new" do
    describe "accessed by an admin" do
      before do
        authenticate(:admin)
      end

      it "should be authorized" do
        get :new
        verify_authorization_successful
      end

      it "assigns all projects as @projects" do
        get :new
        expect(assigns[:projects]).to include(@project)
      end

      describe "has a project_id" do
        let :project_report do
          double(ProjectReport)
        end

        before do
          ProjectReport.should_receive(:new).and_return(project_report)
          get :new, :project_id => @project.id
        end

        it "should assign a project as @project" do
          expect(assigns[:project]).to eq(@project)
        end

        it "creates a project report" do
          expect(assigns[:project_report]).to eq(project_report)
        end
      end

    end

    describe "accessed by not an admin" do
      it "should not be authorized" do
        get :new
        verify_authorization_unsuccessful
      end
    end
  end

end