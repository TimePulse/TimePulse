  require 'spec_helper'

  describe ActivitiesController do

    before(:each) do
      @base_time = Time.now.beginning_of_day-1.day+12.hours
      @user = FactoryGirl.create(:user)
      @project = FactoryGirl.create(:project)
      @project_different = FactoryGirl.create(:project)
      #create activity and work_unit that both have the same project associated
      @activity = FactoryGirl.create(:activity, :project => @project, :user => @user)
      @current_work_unit = FactoryGirl.create(:work_unit, :project => @project, :start_time => @base_time, :stop_time => nil, :user => @user, :hours => nil, :notes => "Work Unit, Clocked in")
      #create activity and work_unit with different projects associated
      @activity_different = FactoryGirl.create(:activity, :project => @project_different, :user => @user)
      @activity_request = {activity: {description: @activity.description, project_id: @activity.project_id, source: @activity.source, time: @base_time, user_id: @user.id}}
    end

    describe "hit endpoint with a post request that saves activity" do
      it "should respond with a 201 status" do
        request.headers["accept"] = 'application/json'
        request.headers["Content-Type"] = 'application/json'
        request.headers["login"] = @user.login
        request.headers["Authorization"] = 'AEsXr_Ec6R_trmAoLd5S'
        post :create, @activity_request
        expect(response.status).to eq(201)
      end

      it "should create a new activity in the database" do
        expect do
          request.headers["accept"] = 'application/json'
          request.headers["Content-Type"] = 'application/json'
          request.headers["login"] = @user.login
          request.headers["Authorization"] = 'AEsXr_Ec6R_trmAoLd5S'
          post :create, @activity_request
        end.to change{
            Activity.where(description: @activity.description).count
            }.from(2).to(3)
      end
    end

    describe "make a new activity that is associated with the current work unit, if clocked_in" do
      it "checks to see if the user is clocked in" do
        expect(@user.clocked_in?).to be true
      end
      it "confirms current_work_unit & activity request have the same project associated" do
        expect(@current_work_unit.project_id).to eq(@activity.project_id)
      end
      it "confirms current_work_unit and activity_different don't have to same project associated"do
        expect(@current_work_unit.project_id).not_to eq(@activity_different.project_id)
      end

    end
  end
