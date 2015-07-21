require 'spec_helper'

describe GithubUpdate do
  
  # See https://developer.github.com/v3/activity/events/types/#pushevent
  # for formatting of a github push webhook.
  let :payload_file do
    File.join(Rails.root, '/spec/support/fixtures/sample_github_payload.txt')
  end

  let :payload_string do
    File.open(payload_file).read
  end

  let :params do
    JSON.parse(payload_string, :symbolize_names => true)
  end

  let :project do
    FactoryGirl.create(:project)
  end
  
  let! :repo do
    FactoryGirl.create(:repository, project: project,
      url: "https://github.com/Correct-User/Repo-One")
  end 


  let! :user do
    FactoryGirl.create(:user, :github_user => "one")
  end

  let :start_time do DateTime.parse("2013-05-23T16:48:39-07:00").advance(:minutes => -15) end
  let :stop_time do DateTime.parse("2013-05-23T16:48:39-07:00").advance(:minutes => 5) end

  let :last_activity do Activity.last end

  describe "save" do
    it "should create two activities" do
      expect do
        github_update = GithubUpdate.new(params)
        github_update.save
      end.to change{Activity.count}.by(2)
    end

    it "should set the parameters properly" do
      github_update = GithubUpdate.new(params)
      github_update.save
      last_activity.source.should == "github"
      last_activity.action.should == "commit"
      last_activity.description.should == "Message 2"
      last_activity.time.should == "2013-05-23T16:48:39-07:00"
      last_activity.properties['id'].should == "sha2"
      last_activity.properties['branch'].should == "master"
      last_activity.project.should == project
      last_activity.user.should == user
    end
  end
end

