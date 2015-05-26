  require 'spec_helper'
  require 'pp'

  describe ActivitiesController do

    before(:each) do
      @activity = FactoryGirl.create(:activity)
    end

    describe "hit endpoint with get request" do
      it "should return all the activities" do
        get :index
        pp response
        pp @activity
        expect(response.status).to eq(200)
      end
    end



  end