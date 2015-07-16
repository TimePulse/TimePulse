require 'spec_helper'

describe GithubPull do
  
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
  
  context "when neither a project nor its ancestors has repositories" do
  
  end

end