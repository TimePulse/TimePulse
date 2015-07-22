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
  
  let! :user do
    FactoryGirl.create(:user, :github_user => "one")
  end

  let :start_time do DateTime.parse("2013-05-23T16:48:39-07:00").advance(:minutes => -15) end
  let :stop_time do DateTime.parse("2013-05-23T16:48:39-07:00").advance(:minutes => 5) end

  let :last_activity do Activity.last end

  context ", when push applies to exactly one repo" do

    let! :repo do
      FactoryGirl.create(:repository, project: project,
        url: "https://github.com/Correct-User/Repo-One")
    end 

    context "and all commits are new, " do
      it "creates two activities" do
        expect do
          github_update = GithubUpdate.new(params)
          github_update.save
        end.to change{Activity.count}.by(2)
      end

      it "sets the parameters properly" do
        github_update = GithubUpdate.new(params)
        github_update.save
        last_activity.source.should == "github"
        last_activity.action.should == "commit"
        last_activity.description.should == "Message 2"
        last_activity.time.should == "2013-05-24T16:48:39-07:00"
        last_activity.properties['id'].should == "sha2"
        last_activity.properties['branch'].should == "master"
        last_activity.project.should == project
        last_activity.user.should == user
      end
    end
    
    context "and some commits are old, " do
      let! :pre_existing_activity do
        FactoryGirl.create(:activity,
          properties: {id: "sha2", branch: "master"},
          project: project)
      end

      it "creates one activity" do
        expect do
          github_update = GithubUpdate.new(params)
          github_update.save
        end.to change{Activity.count}.by(1)
      end

      it "sets the parameters properly" do
        github_update = GithubUpdate.new(params)
        github_update.save
        last_activity.source.should == "github"
        last_activity.action.should == "commit"
        last_activity.description.should == "Message 1"
        last_activity.time.should == "2013-05-23T16:48:39-07:00"
        last_activity.properties['id'].should == "sha1"
        last_activity.properties['branch'].should == "master"
        last_activity.project.should == project
        last_activity.user.should == user
      end
    end
  end
  
  context ", when push applies to no repos," do
    let! :repo do
      FactoryGirl.create(:repository, project: project,
        url: "https://github.com/Incorrect-User/No-Repo")
    end 

    it "creates no activities" do
      expect do
        GithubUpdate.new(params).save
      end.not_to change{Activity.count}
    end
    
    it "logs the event" do
      Rails.logger.should_receive(:warn)
      GithubUpdate.new(params).save
    end
  end
  
  context ", when push applies to multiple repos" do
    let! :repo_one do
      FactoryGirl.create(:repository, project: project,
        url: "https://github.com/Correct-User/Repo-One")
    end 
    
    let :other_project do
      FactoryGirl.create(:project)
    end
    
    let! :repo_two do
      FactoryGirl.create(:repository, project: other_project,
        url: "http://github.com/Correct-User/Repo-One")
    end 

    context "and all commits are new," do
      it "creates a new activity per commit per repo" do
        expect do
          expect do
            expect do
              GithubUpdate.new(params).save
            end.to change {project.activities.count}.by(2)
          end.to change {other_project.activities.count}.by(2)
        end.to change {Activity.count}.by(4)
      end
    end
    
    context "and some commits are pre-existing," do
      let! :pre_existing_activity do
        FactoryGirl.create(:activity,
          properties: {id: "sha2", branch: "master"},
          project: project)
      end

      it "creates new activities, but does not create pre-existing ones" do
        expect do
          expect do
            expect do
              GithubUpdate.new(params).save
            end.to change {project.activities.count}.by(1)
          end.to change {other_project.activities.count}.by(2)
        end.to change {Activity.count}.by(3)
      end
      
      it "creates new activities, but does not create pre-existing ones" do
        expect do
          expect do
            expect do
              GithubUpdate.new(params).save
            end.to change {project.activities.count}.by(1)
          end.to change {other_project.activities.count}.by(2)
        end.to change {Activity.count}.by(3)
      end
      
      it "does not update pre-existing commits" do
        GithubUpdate.new(params).save
        pre_existing_activity.time.should_not == "2013-05-24T16:48:39-07:00"
      end
      
    end
  end
  
end

