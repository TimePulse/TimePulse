require 'spec_helper'

describe CalendarWorkUnitsController do
  describe "GET Index" do
    describe "While logged in" do
      let! :user do FactoryGirl.create(:user) end
      let! :user_work_units do FactoryGirl.create(:work_unit, :user => user, :hours => 4) end
      let! :non_user_work_units do FactoryGirl.create(:work_unit, :hours => 7) end
      describe "with no parameters" do
        before :each do
         authenticate(user)
         get :index
        end
        it "should be authorized" do
          verify_authorization_successful
        end
        it "should have an instance variable for work_units" do\
          assigns[:work_units].should include(user_work_units)
          assigns[:work_units].should_not include(non_user_work_units)
        end
      end
      describe "with start and end parameters" do
        let! :user_work_units_in_range do FactoryGirl.create(:work_unit, :start_time => Time.now-36.hours, :stop_time => Time.now-30.hours, :hours => 6, :user => user) end
        let! :user_work_units_out_of_range do FactoryGirl.create(:work_unit, :start_time => Time.now-90.hours, :stop_time => Time.now-60.hours, :hours =>30, :user => user) end
        before :each do
         authenticate(user)
         get :index, :start => Time.now-2.days, :end => Time.now-1.days
        end
        it "should be authorized" do
          verify_authorization_successful
        end
        it "should have an instance variable for work_units" do
          assigns[:work_units].should include(user_work_units_in_range)
          assigns[:work_units].should_not include(user_work_units_out_of_range)
          assigns[:work_units].should_not include(non_user_work_units)
        end
        it "should have an instance variable for start and end time" do
          assigns[:start_time].to_s.should == (Time.now-2.days).to_s
          assigns[:end_time].to_s.should == (Time.now-1.days).to_s
        end
      end
    end
    describe "While not logged in" do
      it "should redirect to the login page" do
        get :index
        verify_authorization_unsuccessful
      end

    end

  end
end