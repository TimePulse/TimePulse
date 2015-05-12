require 'spec_helper'

describe HoursReportsController do

  describe "as an admin" do
    before(:each) do
      authenticate(:admin)
    end

    before do
      Timecop.travel(Time.local(2015, 4, 27, 0, 0, 0))
    end

    let! :user_1 do FactoryGirl.create(:user, :name => "Foo Bar 1") end
    let! :user_2 do FactoryGirl.create(:user, :name => "Foo Bar 2") end
    let! :project_1 do FactoryGirl.create(:project) end
    let! :project_2 do FactoryGirl.create(:project) end
    let! :work_unit_1 do
      FactoryGirl.create(:work_unit, :hours => 5, :user => user_1, :project => project_1, :start_time => Time.now - 2.weeks, :stop_time => Time.now - 10.days)
    end
    let! :work_unit_2 do
      FactoryGirl.create(:work_unit, :hours => 5, :user => user_2, :project => project_2, :start_time => Time.now - 8.weeks, :stop_time => Time.now - 7.weeks)
    end
    let! :admin do FactoryGirl.create(:admin) end

    describe "responding to GET index" do

      it "should be a successful request" do
        get :index
        expect(response).to be_success
      end

      it "should show the appropriate users" do
        get :index
        expect(assigns(:users)).to_not be_empty
        expect(assigns(:users)).to include(user_1)
        expect(assigns(:users)).to_not include(user_2)
      end

      it "should show the appropriate Sundays" do
        get :index
        expect(assigns(:sundays)).to include((DateTime.now.beginning_of_week - 1.day).strftime('%b %d %y'))
        expect(assigns(:sundays)).to_not include((DateTime.now.beginning_of_week - 43.days).strftime('%b %d %y'))
      end

    end

    after do
      Timecop.return
    end

  end
end
