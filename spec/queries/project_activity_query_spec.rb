require 'spec_helper'

describe ProjectActivityQuery do
  let :root_project do Project.root end

  before :each do
    @project1 = FactoryGirl.create(:project)
    @subproject = FactoryGirl.create(:project, :parent => @project1)
    @project1.reload
    @project2 = FactoryGirl.create(:project)
    @user1 = FactoryGirl.create(:user)
    @user2 = FactoryGirl.create(:user)
    @activity_for_project1 = FactoryGirl.create(:activity, :project => @project1, :user => @user1)
    @activity_for_project2 = FactoryGirl.create(:activity, :project => @project2, :user => @user1)
    @activity_for_subproject = FactoryGirl.create(:activity, :project => @subproject, :user => @user1)
    @activity_for_other_user = FactoryGirl.create(:activity, :project => @project2, :user => @user2)
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
