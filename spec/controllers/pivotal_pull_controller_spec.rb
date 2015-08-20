require 'spec_helper'
require 'pivotal-tracker'

describe PivotalPullController, :vcr => {} do
  before do
    @project = FactoryGirl.create(:project)
  end

  describe "accessed by a normal user" do
    before(:each) do
      authenticate(:user)
    end

    describe "forbidden actions" do

      it "should include POST create" do
        post :create, :project_id => @project
      end

      after do
        verify_authorization_unsuccessful
      end
    end
  end

  describe "accessed by an admin" do
    before do
      authenticate(:admin)
    end

    describe "POST create" do
      let :pivotal_project do
        FactoryGirl.create(:project, :pivotal_id => 12345)
      end

      let :activities do
        (1..3).map do |n|
          double(:activity).as_null_object.tap do |activity|
            activity.stub(:stories => [])
            activity.stub(:project_id => pivotal_project.id)
            activity.stub(:id) { n }
            activity.stub(:occurred_at) { Time.now.utc }
          end
        end
      end

      let(:number_of_activities_for_project){ 3 }

      before do
        unless defined?(::API_KEYS)
          ::API_KEYS = {}
          ::API_KEYS.stub(:[]).with(:pivotal) { 'xxxxx' }
        end
        PivotalActivity.any_instance.stub(:project) { pivotal_project }
        PivotalTracker::Project.stub_chain(:find, :activities, :all => activities)
      end

      it "should get git commits" do
        post :create, :project_id => pivotal_project
        assigns(:pivotal_pull).activities.count.should == number_of_activities_for_project
      end

      it "should save them to the database, but not resave on a subsequent pull" do
        expect do
          post :create, :project_id => pivotal_project
        end.to change{Activity.count}.by(number_of_activities_for_project)
        expect do
          Activity.any_instance.should_not_receive(:save)
          post :create, :project_id => pivotal_project
        end.to_not change{Activity.count}
      end
    end
  end
end
