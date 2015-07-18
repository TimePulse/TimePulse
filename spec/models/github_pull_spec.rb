require 'spec_helper'

describe GithubPull do
  
  let :project do
    FactoryGirl.create(:project)
  end
  
  let :child_project do
    FactoryGirl.create(:project, parent: project)
  end
  
  let :randy_scouse_git do
    mash = Hashie::Mash.new({
      "sha"=>"sha1",
      "commit"=>
        {"author"=>
            {"name"=>"Mickey Dolenz",
              "email"=>"Mickey@monkees.com",
              "date"=>"2015-05-22T17:23:02Z"},
          "message"=>"Commit 2"
          },
      "html_url"=>
        "https://github.com/Monkees/Randy-Scouse/commit/sha1",
      "author"=>
        {"login"=>"CircusBoy"}
      })
    aftermash = Hashie::Mash.new({
      "sha"=>"sha2",
      "commit"=>
        {"author"=>
            {"name"=>"Peter Tork",
              "email"=>"Peter@monkees.com",
              "date"=>"2015-05-23T17:23:02Z"},
          "message"=>"Commit 2"
          },
      "html_url"=>
        "https://github.com/Monkees/Randy-Scouse/commit/sha2",
      "author"=>
        {"login"=>"TorkWrench"}
      })
    [mash, aftermash]
  end
  
  before :each do
    unless defined?(::API_KEYS)
      ::API_KEYS = {}
      ::API_KEYS.stub(:[]).with(:github) { 'xxxxx' }
    end
      
    Github::Client.any_instance.stub_chain(:repos, :commits, :all) do
      randy_scouse_git
    end
  end

  context "when a project has one repository" do

    let! :repo do
      FactoryGirl.create(:repository, project: project,
        url: "https://github.com/Monkees/Randy-Scouse")
    end 

    context "when github returns changes" do

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
      
    end

  end
  
  context "when a project has no repository, but an ancestor has one" do
    
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