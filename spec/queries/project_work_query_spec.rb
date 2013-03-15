require 'spec_helper'

describe ProjectWorkQuery do
  let :root_project do Project.root end

  before :each do
    @project1 = Factory(:project)
    @subproject = Factory(:project, :parent => @project1)
    @project1.reload
    @project2 = Factory(:project)
    @user1 = Factory(:user)
    @user2 = Factory(:user)
    @work_unit_for_project1 = Factory(:work_unit, :project => @project1, :user => @user1)
    @work_unit_for_project2 = Factory(:work_unit, :project => @project2, :user => @user1)
    @work_unit_for_subproject = Factory(:work_unit, :project => @subproject, :user => @user1)
    @work_unit_for_other_user = Factory(:work_unit, :project => @project2, :user => @user2)
  end


  describe "without exclusive" do
    it "should find all work_units for specified project" do
      @query = ProjectWorkQuery.new
      @results = @query.find_for_project(@project1, false)
      @results.count.should == 2
      @results.should include(@work_unit_for_project1)
      @results.should include(@work_unit_for_subproject)
    end
  end

  describe "with exclusive" do
    
    it "should find all work_units for specified project" do
      @query = ProjectWorkQuery.new
      @results = @query.find_for_project(@project1, true)
      @results.count.should == 1
      @results.should include(@work_unit_for_project1)
      @results.should_not include(@work_unit_for_subproject)
    end
  end

  describe "with an existing relationship" do
    it "should find all work_units for specified project that satisfy the existing relationship" do
      @query_for_user = ProjectWorkQuery.new(WorkUnit.where(:user_id => @user1))
      @results = @query_for_user.find_for_project(@project2, true)
      @results.count.should == 1
      @results.should include(@work_unit_for_project2)
      @results.should_not include(@work_unit_for_other_user)
    end
  end
end