require 'spec_helper'

describe GithubPull do
  
  let :project do
    FactoryGirl.create(:project)
  end
  
  let :child_project do
    FactoryGirl.create(:project, parent: project)
  end
  
  context "when the project has a repository" do

    context "when github returns no changes" do
    end

    context "when github returns changes" do

      context "that are new" do
      end
      
      context "that have been recorded" do
      end

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
    end
    
    it "shouldn't call the API" do
      expect(Github).not_to receive_message(:new)
      GithubPull.new(project_id: project.id).save
    end
  
  end

  context "when a project and its ancestors have no repositories" do

    it "shouldn't change the activity count" do
    end
    
    it "shouldn't call the API" do
      expect(Github).not_to receive_message(:new)
      GithubPull.new(project_id: child_project.id).save
    end
  
  end

end