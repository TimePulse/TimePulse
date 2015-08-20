# == Schema Information
#
# Table name: users
#
#  id                  :integer(4)      not null, primary key
#  login               :string(255)     not null
#  email               :string(255)     not null
#  current_project_id  :integer(4)
#  name                :string(255)     not null
#  crypted_password    :string(255)     not null
#  password_salt       :string(255)     not null
#  persistence_token   :string(255)     not null
#  single_access_token :string(255)     not null
#  perishable_token    :string(255)     not null
#  login_count         :integer(4)      default(0), not null
#  failed_login_count  :integer(4)      default(0), not null
#  last_request_at     :datetime
#  current_login_at    :datetime
#  last_login_at       :datetime
#  current_login_ip    :string(255)
#  last_login_ip       :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do
  before(:each) do
    @valid_attributes = {
      :login => "NewUser",
      :password => "12345678",
      :password_confirmation => "12345678",
      :email => "newuser@newuser.com",
      :name => "New User"
    }
  end

  it "should create a new instance given valid attributes" do
    User.unsafe_create(@valid_attributes)
  end

  it "should succeed creating a new :user from the Factory" do
    FactoryGirl.create(:user)
  end

  describe "current_work_unit" do
    before(:each) do
      @user = FactoryGirl.create(:user)
    end
    it "should return a work_unit that is in_progress" do
      @wu1 = FactoryGirl.create(:in_progress_work_unit, :user => @user)
      @user.reload.current_work_unit.should == @wu1
    end
    it "should not return a completed work_unit" do
      @wu1 = FactoryGirl.create(:work_unit, :user => @user)
      @user.reload.current_work_unit.should be_nil
    end
  end

  describe "clocked_in?" do
    before(:each) do
      @user = FactoryGirl.create(:user)
    end
    it "should return false if the user has no work units" do
      @user.should_not be_clocked_in
    end
    it "should return true if the user has a work_unit that is in_progress" do
      @wu1 = FactoryGirl.create(:in_progress_work_unit, :user => @user)
      @user.should be_clocked_in
    end
    it "should return false if the user only has completed work units" do
      @wu1 = FactoryGirl.create(:work_unit, :user => @user)
      @wu2 = FactoryGirl.create(:work_unit, :user => @user)
      @user.should_not be_clocked_in
    end

  end

  describe "work_units association" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      @user2 = FactoryGirl.create(:user)
      @wu1 = FactoryGirl.create(:work_unit, :user => @user)
      @wu2 = FactoryGirl.create(:work_unit, :user => @user)
      @wu3 = FactoryGirl.create(:work_unit, :user => @user2)
    end

    it "should return work units assigned to the user" do
      @user.work_units.should include(@wu1)
      @user.work_units.should include(@wu2)
    end

    it "should not return work units assigned to other users" do
      @user.work_units.should_not include(@wu3)
    end
  end

  describe "activities association" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      @user2 = FactoryGirl.create(:user)
      @proj = FactoryGirl.create(:project)
      @ac1 = FactoryGirl.create(:activity, :user => @user, :project => @proj)
      @ac2 = FactoryGirl.create(:activity, :user => @user, :project => @proj)
      @ac3 = FactoryGirl.create(:activity, :user => @user2, :project => @proj)
    end

    it "should return work units assigned to the user" do
      @user.activities.should include(@ac1)
      @user.activities.should include(@ac2)
    end

    it "should not return work units assigned to other users" do
      @user.activities.should_not include(@ac3)
    end
  end

  describe "work_units_for" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      @proj = FactoryGirl.create(:project)
      @wu1 = FactoryGirl.create(:work_unit, :user => @user, :project => @proj, :hours => 3.0)
    end
    it "should return a work unit associated with the specified project" do
      @user.completed_work_units_for(@proj).should include(@wu1)
    end
    it "should return a work unit associated with a subproject" do
      @proj2 = FactoryGirl.create(:project, :parent => @proj)
      @proj.reload.self_and_descendants.should include(@proj2)
      @wu2 = FactoryGirl.create(:work_unit, :user => @user, :project => @proj2, :hours => 3.0)
      @user.completed_work_units_for(@proj).should include(@wu2)
    end
    it "should not return a work unit for another user" do
      @other = FactoryGirl.create(:user)
      @wu3 = FactoryGirl.create(:work_unit, :user => @other, :project => @proj, :hours => 3.0)
      @user.completed_work_units_for(@proj).should_not include(@wu3)
    end
    it "should not return a work unit for a project outside the heirarchy" do
      @proj3 = FactoryGirl.create(:project)
      @wu3 = FactoryGirl.create(:work_unit, :user => @user, :project => @proj3, :hours => 3.0)
      @user.completed_work_units_for(@proj).should_not include(@wu3)
    end
    it "should not include a work unit for a parent project" do
      @proj2 = FactoryGirl.create(:project, :parent => @proj)
      @proj.reload.self_and_descendants.should include(@proj2)
      @user.completed_work_units_for(@proj2).should_not include(@wu1)
    end
  end

  describe "activties_for" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      @proj = FactoryGirl.create(:project)
      @ac1 = FactoryGirl.create(:activity, :user => @user, :project => @proj, :source => "github")
    end

    it "should return an activity associated with the specified project" do
      @user.git_commits_for(@proj).should include(@ac1)
    end

    it "should return an activity associated with a subproject" do
      @proj2 = FactoryGirl.create(:project, :parent => @proj)
      @proj.reload.self_and_descendants.should include(@proj2)
      @ac2 = FactoryGirl.create(:activity, :user => @user, :project => @proj2, :source => "github")
      @user.git_commits_for(@proj).should include(@ac2)
    end

    it "should not return a work unit for another user" do
      @other = FactoryGirl.create(:user)
      @ac3 = FactoryGirl.create(:activity, :user => @other, :project => @proj, :source => "github")
      @user.git_commits_for(@proj).should_not include(@ac3)
    end
    it "should not return a work unit for a project outside the heirarchy" do
      @proj3 = FactoryGirl.create(:project)
      @ac3 = FactoryGirl.create(:activity, :user => @user, :project => @proj3, :source => "github")
      @user.git_commits_for(@proj).should_not include(@ac3)
    end
    it "should not include a work unit for a parent project" do
      @proj2 = FactoryGirl.create(:project, :parent => @proj)
      @proj.reload.self_and_descendants.should include(@proj2)
      @user.git_commits_for(@proj2).should_not include(@ac1)
    end
    it "should include an activity if only the parent has a github/pivotal url" do
      @repository = FactoryGirl.create(:repository, :project => @proj, :url => "https://github.com/Awesome")
      @proj2 = FactoryGirl.create(:project, :parent => @proj)
      @proj.reload.self_and_descendants.should include(@proj2)
      @user.git_commits_for(@proj2).should include(@ac1)
    end
  end

  describe "rate_for" do
    before :each do
      @user = FactoryGirl.create(:user)
      @rate = FactoryGirl.create(:rate)
      @project = FactoryGirl.create(:project)
    end

    it "should return a user's rate for a given project" do
      @rate.users << @user
      @rate.project = @project
      @project.rates << @rate

      @user.rate_for(@project).should == @rate
    end
  end

  describe "user_preferences" do
    before :each do
      @user = FactoryGirl.create(:user)
    end

    it "should change a user's recent_projects preference" do
      @user.user_preferences.recent_projects_count.should == 5
    end
  end

  describe "recent_projects" do

    let :user do FactoryGirl.create(:user) end

    let! :projects do
      array_of_projects = []
      5.times do
        array_of_projects << FactoryGirl.build_stubbed(:project)
      end
      array_of_projects
    end

    let :work_units do
      array = []
      20.times do |nn|
        array << FactoryGirl.build_stubbed(:work_unit, :user => user, :project => projects[nn % 5])
      end
      array
    end

    before do
      WorkUnit.stub_chain(:user_work_units, :most_recent).and_return(work_units)
      Project.stub(:find).and_return(projects)
    end

    it "returns items with unique projects" do
      user.recent_projects.uniq.count.should == user.recent_projects.count.should
    end

    it "gives back the number specified by the user preferences" do
      user.recent_projects.count.should == user.user_preferences.recent_projects_count
    end
  end
end