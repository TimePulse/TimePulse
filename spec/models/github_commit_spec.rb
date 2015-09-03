require 'spec_helper'

describe GithubCommit do

  let! :project do FactoryGirl.create(:project) end
  let! :user do FactoryGirl.create(:user, :email => "george@jungle.com", :github_user => "georgeofjungle") end

  let :timestamp do "2013-05-23T16:48:39-07:00" end
  let :start_time do DateTime.parse(timestamp).advance(hours: -5) end
  let :stop_time do DateTime.parse(timestamp).advance(hours: 5) end

  let :commit_params do
    {
    :id        => "1234",
    :message   => "Fixed some stuff",
    :url       => "http://github.com/Awesome/McAwesome/master/abc",
    :added     => [],
    :removed   => [],
    :modified  => [],
    :author    => {
      :name  => "George of the Jungle",
      :email => "george@jungle.com",
    },
    :branch => "1234_fix_stuff"
    }
  end

  let :valid_commit_params do
    params = commit_params
    params[:timestamp] = timestamp
    params[:project_id] = project.id
    params[:author][:username] = "georgeofjungle"
    params
  end

  let :no_user_params do
    params = commit_params
    params[:timestamp] = timestamp
    params[:project_id] = project.id
    params
  end

  let :invalid_commit_params do
    params = commit_params
    params[:timestamp] = timestamp
    params[:project_id] = nil
    params[:author][:username] = "georgeofjungle"
    params
  end

  let :last_activity do Activity.last end

  describe "save" do

    describe "with valid data" do

      it "should create a new activity" do
        expect do
          github_commit = GithubCommit.new(valid_commit_params)
          github_commit.save
        end.to change{Activity.count}.by(1)
      end

      it "should associate a user" do
        github_commit = GithubCommit.new(valid_commit_params)
        github_commit.save
        last_activity.user.should == user
      end

      it "should associate a project" do
        github_commit = GithubCommit.new(valid_commit_params)
        github_commit.save
        last_activity.project.should == project
      end

      it "should set the activity values appropriately" do
        github_commit = GithubCommit.new(valid_commit_params)
        github_commit.save
        last_activity.source.should == "github"
        last_activity.action.should == "commit"
        last_activity.description.should == "Fixed some stuff"
        last_activity.time.should == timestamp
        last_activity.source_id.should == "1234"
        last_activity.properties['branch'].should == "1234_fix_stuff"
      end

      it "should associate a user by email" do
        github_commit = GithubCommit.new(no_user_params)
        github_commit.save
        last_activity.user.should == user
      end

      describe "and a closed work unit" do
        let! :work_unit do
          FactoryGirl.create(:work_unit,
            start_time: start_time,
            stop_time: stop_time,
            hours: 8,
            notes: "Work Unit Notes",
            user: user,
            project: project)
        end
        it "should associate to the work unit" do
          github_commit = GithubCommit.new(valid_commit_params)
          github_commit.save
          last_activity.work_unit.should == work_unit
        end
      end

      describe "and an in-progress work unit" do
        let! :work_unit do
          FactoryGirl.create(:in_progress_work_unit,
            start_time: start_time,
            notes: "Work Unit Notes",
            user: user,
            project: project)
        end
        it "should associate to the work unit" do
          github_commit = GithubCommit.new(valid_commit_params)
          github_commit.save
          last_activity.work_unit.should == work_unit
        end
      end

      describe "and a inapplicable work unit" do
        let! :work_unit do
          FactoryGirl.create(:work_unit,
            start_time: DateTime.parse(timestamp).advance(hours: -5),
            stop_time: DateTime.parse(timestamp).advance(hours: -3),
            hours: 1,
            notes: "Work Unit Notes",
            user: user,
            project: project)
        end

        it "should not associate to the work unit" do
          github_commit = GithubCommit.new(valid_commit_params)
          github_commit.save
          last_activity.work_unit.should == nil
        end
      end

    end

    describe "with invalid data" do

      it "should not create an activity" do
        expect do
          github_commit = GithubCommit.new(invalid_commit_params)
          github_commit.save
        end.to change{Activity.count}.by(0)
      end

    end

  end

end
