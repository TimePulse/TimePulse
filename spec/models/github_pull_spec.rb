require 'spec_helper'

describe GithubPull do
  
  let :project do
    FactoryGirl.create(:project)
  end
  
  let :child_project do
    FactoryGirl.create(:project, parent: project)
  end
  
  # This method returns an array of mashes to simulate the results of the
  # Github API call for a list of commits.
  def github_hashie(user, repo) 
    if user == "Correct-User" && repo == "Repo-One" 
      mash = Hashie::Mash.new({
        "sha"=>"sha1",
        "commit"=>
          {"author"=>
              {"name"=>"Primo Furst",
                "email"=>"one@example.com",
                "date"=>"2015-05-22T17:23:02Z"},
            "message"=>"Commit 1"
            },
        "html_url"=>
          "https://github.com/Correct-User/Repo-One/commit/sha1",
        "author"=>
          {"login"=>"one"}
        })
      aftermash = Hashie::Mash.new({
        "sha"=>"sha2",
        "commit"=>
          {"author"=>
              {"name"=>"Segundo Dos",
                "email"=>"two@example.com",
                "date"=>"2015-05-23T17:23:02Z"},
            "message"=>"Commit 2"
            },
        "html_url"=>
          "https://github.com/Correct-User/Repo-One/commit/sha2",
        "author"=>
          {"login"=>"two"}
        })
      [mash, aftermash]
    else
      []
    end
  end
  
  before :each do
    unless defined?(::API_KEYS)
      ::API_KEYS = {}
      ::API_KEYS.stub(:[]).with(:github) { 'xxxxx' }
    end

    Github.stub(:new) do | args |
      gh_double = double()
      gh_double.stub(:user).and_return(args[:user])
      gh_double.stub(:repo).and_return(args[:repo])
      gh_double.stub_chain(:repos, :commits, :all) do
        github_hashie(gh_double.user, gh_double.repo)
      end
      gh_double
    end

  end

  context "when a project has one repository" do

    context "when github returns changes" do

      let! :repo do
        FactoryGirl.create(:repository, project: project,
          url: "https://github.com/Correct-User/Repo-One")
      end 

      context "that are new" do
        it "should create activities" do
          expect do
            GithubPull.new(project_id: project.id).save
          end.to change{Activity.count}.by(2)
        end
      end
      
      context "that have been recorded" do
        let! :pre_existing_activity do
          FactoryGirl.create(:activity,
                             properties: {id: "sha1", branch: "master"},
                             project: project)
        end
        
        it "should only create new activities" do
          expect do
            GithubPull.new(project_id: project.id).save
          end.to change{Activity.count}.by(1)
        end
        
        it "should not modify preexisting activities" do
          GithubPull.new(project_id: project.id).save
          pre_existing_activity.time.should_not == "2015-05-22T17:23:02Z"
        end

      end

    end

    context "when github returns no changes" do
      let! :repo do
        FactoryGirl.create(:repository, project: project,
          url: "https://github.com/Incorrect-User/Repo-One")
      end 
      
      it "should call the API" do
        Github.should_receive(:new)
        GithubPull.new(project_id: project.id).save
      end
      
      it "shouldn't change the activity count" do
        expect do
          GithubPull.new(project_id: child_project.id).save
        end.to_not change{Activity.count}
      end
        
    end

  end
  
  context "when a project has no repository, but an ancestor has one" do
    let! :repo do
      FactoryGirl.create(:repository, project: project,
        url: "https://github.com/Correct-User/Repo-One")
    end 
    
    it "should create activities belonging to the ancestor" do
      expect do
        GithubPull.new(project_id: child_project.id).save
      end.to change{project.activities.count}.by(2)
    end

    it "should not create activities belonging to the child" do
      expect do
        GithubPull.new(project_id: child_project.id).save
      end.not_to change{child_project.activities.count}
    end
    
  end
  
  context "when a project has multiple repositories" do
    
    context "when github returns changes on more than one" do
    end
    
    context "when github returns changes on none" do
    end
    
  end
  
  context "when a project has no repositories" do

    it "shouldn't change the activity count" do
      expect do
        GithubPull.new(project_id: project.id).save
      end.to_not change{Activity.count}
    end
    
    it "shouldn't call the API" do
      Github.should_not_receive(:new)
      GithubPull.new(project_id: project.id).save
    end
  
  end

  context "when a project and its ancestors have no repositories" do

    it "shouldn't change the activity count" do
      expect do
        GithubPull.new(project_id: child_project.id).save
      end.to_not change{Activity.count}
    end
    
    it "shouldn't call the API" do
      Github.should_not_receive(:new)
      GithubPull.new(project_id: child_project.id).save
    end
  
  end

end