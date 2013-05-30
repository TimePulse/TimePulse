require 'spec_helper'

describe GithubCommit do

  let! :project do Factory.create(:project) end
  let! :user do Factory.create(:user, :email => "george@jungle.com", :github_user => "georgeofjungle") end

  let! :timestamp do DateTime.parse(2.days.ago.to_s).xmlschema end
  let! :close_time do DateTime.parse((1.day.ago.advance(:minutes => 5)).to_s).xmlschema end
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
        last_activity.reference_1.should == "1234"
        last_activity.reference_2.should == "1234_fix_stuff"
      end
    
      it "should associate a user by email" do
        github_commit = GithubCommit.new(no_user_params)
        github_commit.save
        last_activity.user.should == user
      end
    end

    describe "with invalid data" do

      it "should not create an activity" do
        expect do
          github_commit = GithubCommit.new(invalid_commit_params)
          github_commit.save
        end.to_not change{Activity.count}.by(1)
      end

    end

  end

end
