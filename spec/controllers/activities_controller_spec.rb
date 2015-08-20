require 'spec_helper'

describe ActivitiesController do

  let :activity_attrs do
    FactoryGirl.attributes_for(:activity, :project => @project, :user => @user)
  end
  before(:each) do
    @base_time = Time.now.beginning_of_day-1.day+12.hours
    @user = FactoryGirl.create(:user)
    @user2 = FactoryGirl.create(:user)
    @project = FactoryGirl.create(:project)
    @project_different = FactoryGirl.create(:project)
    #create activity and work_unit that both have the same project associated

    @current_work_unit = FactoryGirl.create(:work_unit, :project => @project,
                                            :start_time => @base_time, :stop_time => nil, :user => @user, :hours => nil,
                                            :notes => "Work Unit, Clocked in")

    @non_current_work_unit = FactoryGirl.create(:work_unit, :project => @project,
                                                :start_time => @base_time, :stop_time => @base_time+1.hours, :hours => 1,
                                                :user => @user, :notes => "Work Unit, Not Clocked in")

    #work unit for a user who is not clocked in
    @closed_work_unit = FactoryGirl.create(:work_unit, :project => @project,
                                           :start_time => @base_time, :stop_time => @base_time+1.hours, :hours => 1,
                                           :user => @user2, :notes => "Work Unit, Not Clocked in")

    #create activity and work_unit with different projects associated
    activity_different_attrs = FactoryGirl.attributes_for(:activity, :project =>
                                                          @project_different, :user => @user)
    @activity_different_request = {activity: {description:
                                              activity_different_attrs[:description], project_id: activity_different_attrs[:project_id],
                                              source: activity_different_attrs[:source], time: @base_time}}
    @activity_request = {
      activity: {
        description: activity_attrs[:description],
        project_id: @project.id,
        source: activity_attrs[:source],
        time: @base_time
      }}
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
        Activity.where(description: activity_attrs[:description]).count
      }.from(0).to(1)
    end
  end

  #all above tests are passing and working as expected.

  describe "make a new activity and associate it with the current work unit, if clocked_in" do
    before(:each) do
      request.headers["accept"] = 'application/json'
      request.headers["Content-Type"] = 'application/json'
      request.headers["login"] = @user.login
      request.headers["Authorization"] = 'AEsXr_Ec6R_trmAoLd5S'
    end

    it "assigns the current work unit id to the new activity" do
      post :create, @activity_request
      expect(assigns(:activity).work_unit_id).to eq(@current_work_unit.id)
    end

    it "confirms current_work_unit and activity_different don't have to same project associated"do
      post :create, @activity_different_request
      expect(assigns(:activity).work_unit_id).to eq(nil)
    end

    it "confirms that work units that have a stop time aren't associated to the activity" do
      request.headers["login"] = @user2.login
      post :create, @activity_request
      expect(assigns(:activity).work_unit_id).to eq(nil)
    end
  end
end
