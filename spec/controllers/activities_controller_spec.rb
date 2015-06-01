  require 'spec_helper'

  describe ActivitiesController do

    before(:each) do
      @activity = FactoryGirl.create(:activity)
      @user = FactoryGirl.create(:user)
      @project = FactoryGirl.create(:project)
    end

    describe "hit endpoint with a post request that saves activity" do
      it "should respond with a 201 status" do
        request.headers["accept"] = 'application/json'
        request.headers["Content-Type"] = 'application/json'
        request.headers["login"] = @user.login
        request.headers["Authorization"] = 'AEsXr_Ec6R_trmAoLd5S'
        post :create, {activity: {description: "UPDATE AUTH TEST", project_id: 1  , source: "QWE"}}
        expect(response.status).to eq(201)
      end
    end
  end
