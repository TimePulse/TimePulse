require 'spec_helper'

describe Api::V1::ProjectsController do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:admin) { FactoryGirl.create(:admin) }
  let!(:project) { FactoryGirl.create(:project)}
  # initialize it

  describe 'GET index' do
    context 'unauthorized' do
      before { get :index }

      it 'returns http 401' do
        response.response_code.should == 401
      end
    end

    context 'with valid request token' do
      before do
        add_token_for(user).to(@request)
        get :index
      end
      subject { JSON.parse response.body }

      it 'wraps around projects' do should include 'projects' end

      it 'returns http 200' do
        response.response_code.should == 200
      end
    end
  end

  describe 'GET show' do
    context 'unauthorized' do
      before { get :show, id: project.id }

      it 'returns http 401' do
        response.response_code.should == 401
      end
    end

    context 'with valid request token' do
      before do
        add_token_for(user).to(@request)
        get :show, id: project.id
      end
      subject { JSON.parse response.body }

      it 'wraps around project' do should include 'project' end
      context 'inside project' do
        subject { JSON.parse(response.body)['project'] }
        it { should include 'id' }
        it { should include "parent_id" }
        it { should include "lft" }
        it { should include "rgt" }
        it { should include "client_id" }
        it { should include "name" }
        it { should include "account" }
        it { should include "description" }
        it { should include "clockable" }
        it { should include "billable" }
        it { should include "flat_rate" }
        it { should include "archived" }
        it { should include "github_url" }
        it { should include "pivotal_id" }
        it { should include "created_at" }
        it { should include "updated_at" }
      end

      it 'returns http 200' do
        response.response_code.should == 200
      end
    end
  end

  describe 'POST create' do
    let :project_params do
      FactoryGirl.build(:project).as_json
    end

    context 'unauthorized' do
      before { post :create, project_params }

      it 'returns http 401' do
        response.response_code.should == 401
      end
    end

    context 'with request token for non-admin user' do
      before do
        add_token_for(user).to(@request)
        post :create, project_params
      end

      it 'returns http 401' do
        response.response_code.should == 401
      end
    end

    context 'with valid request token for admin' do
      before do
        add_token_for(admin).to(@request)
      end

      context 'with valid_data' do
        it "should create a project" do
          expect do
            post :create, project_params
          end.to change{Project.count}.by(1)
        end

        it 'returns http 200' do
          post :create, project_params
          response.response_code.should == 201
        end
      end

      context 'with invalid data' do
        let :project_params do
          {:project => {} }
        end

        it "should not create a project" do
          expect do
            post :create, project_params
          end.to_not change{Project.count}.by(1)
        end

        it 'returns unprocessable_entity' do
          post :create, project_params
          response.response_code.should == 422
        end
      end

    end
  end

end