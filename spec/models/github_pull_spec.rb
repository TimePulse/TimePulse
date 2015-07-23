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
    elsif user == "Correct-User" && repo == "Repo-Two" 
      mash = Hashie::Mash.new({
        "sha"=>"sha3",
        "commit"=>
          {"author"=>
              {"name"=>"Trip Thurd",
                "email"=>"three@example.com",
                "date"=>"2015-05-24T17:23:02Z"},
            "message"=>"Commit 1"
            },
        "html_url"=>
          "https://github.com/Correct-User/Repo-Two/commit/sha3",
        "author"=>
          {"login"=>"three"}
        })
      aftermash = Hashie::Mash.new({
        "sha"=>"sha4",
        "commit"=>
          {"author"=>
              {"name"=>"Cater Forth",
                "email"=>"four@example.com",
                "date"=>"2015-05-25T17:23:02Z"},
            "message"=>"Commit 2"
            },
        "html_url"=>
          "https://github.com/Correct-User/Repo-Two/commit/sha4",
        "author"=>
          {"login"=>"four"}
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

  context ", when a project has one repository" do

    context "and github returns changes" do

      let! :repo do
        FactoryGirl.create(:repository, project: project,
          url: "https://github.com/Correct-User/Repo-One")
      end 

      context "that are new," do
        it "creates activities" do
          expect do
            GithubPull.new(project_id: project.id).save
          end.to change{Activity.count}.by(2)
        end
      end
      
      context "that have been recorded," do

        # FG having trouble building activities, creating manually instead
        before :each do
          act = Activity.new
          act.project = project
          act.source = "github"
          act.source_id = "sha2"
          act.time = Time.now
          act.save!
        end
        
        it "only creates new activities" do
          expect do
            GithubPull.new(project_id: project.id).save
          end.to change{Activity.count}.by(1)
        end
        
        it "does not modify preexisting activities" do
          GithubPull.new(project_id: project.id).save
          Activity.where(project: project, source_id: "sha2").first.time.
                   should_not == "2015-05-22T17:23:02Z"
        end

      end

    end

    context "and github returns no changes," do
      let! :repo do
        FactoryGirl.create(:repository, project: project,
          url: "https://github.com/Incorrect-User/Repo-One")
      end 
      
      it "calls the API" do
        Github.should_receive(:new)
        GithubPull.new(project_id: project.id).save
      end
      
      it "doesn't change the activity count" do
        expect do
          GithubPull.new(project_id: child_project.id).save
        end.to_not change{Activity.count}
      end
        
    end

  end
  
  context ", when a project has no repository, but an ancestor has one," do
    let! :repo do
      FactoryGirl.create(:repository, project: project,
        url: "https://github.com/Correct-User/Repo-One")
    end 
    
    it "creates activities belonging to the ancestor" do
      expect do
        GithubPull.new(project_id: child_project.id).save
      end.to change{project.activities.count}.by(2)
    end

    it "does not create activities belonging to the child" do
      expect do
        GithubPull.new(project_id: child_project.id).save
      end.not_to change{child_project.activities.count}
    end
    
  end
  
  context ", when a project has multiple repositories" do

    context "and github returns changes on more than one," do
      let! :repo_one do
        FactoryGirl.create(:repository, project: project,
          url: "https://github.com/Correct-User/Repo-One")
      end 

      let! :repo_two do
        FactoryGirl.create(:repository, project: project,
          url: "https://github.com/Correct-User/Repo-Two")
      end

      it "creates activities" do
        expect do
          GithubPull.new(project_id: project.id).save
        end.to change{Activity.count}.by(4)
      end
    end
    
    context "and github returns changes on none," do
      let! :repo_one do
        FactoryGirl.create(:repository, project: project,
          url: "https://github.com/Incorrect-User/Repo-One")
      end 

      let! :repo_two do
        FactoryGirl.create(:repository, project: project,
          url: "https://github.com/Correct-User/Repo-Incorrect")
      end
      
      it "does not change the Activities count" do
        expect do
          GithubPull.new(project_id: child_project.id).save
        end.to_not change{Activity.count}
      end
      
    end
    
  end
  
  context ", when a project has no repositories," do

    it "doesn't change the activity count" do
      expect do
        GithubPull.new(project_id: project.id).save
      end.to_not change{Activity.count}
    end
    
    it "doesn't call the API" do
      Github.should_not_receive(:new)
      GithubPull.new(project_id: project.id).save
    end
  
  end

  context ", when a project and its ancestors have no repositories," do

    it "doesn't change the activity count" do
      expect do
        GithubPull.new(project_id: child_project.id).save
      end.to_not change{Activity.count}
    end
    
    it "doesn't call the API" do
      Github.should_not_receive(:new)
      GithubPull.new(project_id: child_project.id).save
    end
  
  end

end