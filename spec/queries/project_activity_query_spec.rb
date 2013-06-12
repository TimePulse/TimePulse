require 'spec_helper'

describe ProjectActivityQuery do
  let :root_project do Project.root end

  before :each do
    @project1 = Factory(:project)
    @subproject = Factory(:project, :parent => @project1)
    @project1.reload
    @project2 = Factory(:project)
    @user1 = Factory(:user)
    @user2 = Factory(:user)
    @activity_for_project1 = Factory(:activity, :project => @project1, :user => @user1)
    @activity_for_project2 = Factory(:activity, :project => @project2, :user => @user1)
    @activity_for_subproject = Factory(:activity, :project => @subproject, :user => @user1)
    @activity_for_other_user = Factory(:activity, :project => @project2, :user => @user2)
  end


  describe "without exclusive" do
    it "should find all activitys for specified project" do
      @query = ProjectActivityQuery.new
      @results = @query.find_for_project(@project1)
      @results.count.should == 2
      @results.should include(@activity_for_project1)
      @results.should include(@activity_for_subproject)
    end
  end

  describe "with exclusive" do
    
    it "should find all activitys for specified project" do
      @query = ProjectActivityQuery.new
      @results = @query.find_for_project(@project1, :exclusive => true)
      @results.count.should == 1
      @results.should include(@activity_for_project1)
      @results.should_not include(@activity_for_subproject)
    end
  end

  describe "with an existing relationship" do
    it "should find all activitys for specified project that satisfy the existing relationship" do
      @query_for_user = ProjectActivityQuery.new(Activity.where(:user_id => @user1))
      @results = @query_for_user.find_for_project(@project2, :exclusive => true)
      @results.count.should == 1
      @results.should include(@activity_for_project2)
      @results.should_not include(@activity_for_other_user)
    end
  end
end