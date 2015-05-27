  require 'spec_helper'
  require 'pp'


  describe ActivitiesController do

    before(:each) do
      @activity = FactoryGirl.create(:activity)
      @user = FactoryGirl.create(:user)
      p @user.login

    end

    describe "hit endpoint with get request" do
      it "should return all the activities" do
        get :index
        expect(response.status).to eq(200)
      end
    end

    describe "hit endpoint with a post request that saves activity" do
      it "should respond with a 201 status" do
        request.headers["accept"] = 'application/json'
        request.headers["Content-Type"] = 'application/json'
        request.headers["login"] = @user.login
        request.headers["Authorization"] = 'AEsXr_Ec6R_trmAoLd5S'
        p post :create, {activity: {description: "UPDATE AUTH TEST EXPICCSAASD", project_id: 4, source: "QWE"}}
        expect(response.status).to eq(201)
      end
    end




  end