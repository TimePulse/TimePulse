require 'spec_helper'

describe GithubController do
  let :payload_file do
    File.join(Rails.root, '/spec/support/fixtures/sample_github_payload.txt')
  end

  let :payload_string do
    File.open(payload_file).read
  end

  let! :project do
    Factory.create(:project, :github_url => "http://github.com/hannahhoward/activerecord-postgis-array")
  end

  let! :user do
    Factory.create(:user, :github_user => "hannahhoward")
  end

  let :start_time do DateTime.parse("2013-05-23T16:48:39-07:00").advance(:minutes => -15) end
  let :stop_time do DateTime.parse("2013-05-23T16:48:39-07:00").advance(:minutes => 5) end

  let! :work_unit do
    Factory.create(:work_unit, 
      :user => user,
      :project => project,
      :start_time => start_time,
      :stop_time => stop_time,
      :hours => 0.1)
  end

  let :last_activity do Activity.last end

  describe "POST create" do
    it "should create an activity" do
      expect do
        post :create, :payload => payload_string
      end.to change{Activity.count}.by(1)
    end

    it "should set the parameters properly" do
      post :create, :payload => payload_string
      last_activity.source.should == "github"
      last_activity.action.should == "commit"
      last_activity.description.should == "Update Version"
      last_activity.time.should == "2013-05-23T16:48:39-07:00"
      last_activity.reference_1.should == "042ec79f159fe8f0b7a520330f05dfda8741cc75"
      last_activity.reference_2.should == "master"
      last_activity.project.should == project
      last_activity.user.should == user
      last_activity.work_unit.should == work_unit
    end
  end
end
