require 'spec_helper'

describe HoursReportsController do

  describe "as an admin" do
    before(:each) do
      authenticate(:admin)
    end

    ########################################################################################
    #                                      GET INDEX
    ########################################################################################
    describe "responding to GET index" do
      # let :project do FactoryGirl.create(:project) end

      it "should be a successful request" do
        get :index
        expect(response).to be_success
      end
    end
  end
end
