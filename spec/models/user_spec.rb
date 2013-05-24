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
    Factory.create(:user)
  end  

  describe "current_work_unit" do
    before(:each) do
      @user = Factory(:user)      
    end
    it "should return a work_unit that is in_progress" do
      @wu1 = Factory(:in_progress_work_unit, :user => @user)
      @user.reload.current_work_unit.should == @wu1
    end
    it "should not return a completed work_unit" do
      @wu1 = Factory(:work_unit, :user => @user)
      @user.reload.current_work_unit.should be_nil
    end    
  end
  
  describe "clocked_in?" do
    before(:each) do
      @user = Factory(:user)      
    end
    it "should return false if the user has no work units" do
      @user.should_not be_clocked_in
    end
    it "should return true if the user has a work_unit that is in_progress" do
      @wu1 = Factory(:in_progress_work_unit, :user => @user)
      @user.should be_clocked_in      
    end
    it "should return false if the user only has completed work units" do
      @wu1 = Factory(:work_unit, :user => @user)
      @wu2 = Factory(:work_unit, :user => @user)
      @user.should_not be_clocked_in            
    end
    
  end
  
  describe "work_units association" do
    before(:each) do
      @user = Factory(:user)
      @user2 = Factory(:user)
      @wu1 = Factory(:work_unit, :user => @user)
      @wu2 = Factory(:work_unit, :user => @user)
      @wu3 = Factory(:work_unit, :user => @user2)
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
      @user = Factory(:user)
      @user2 = Factory(:user)
      @proj = Factory(:project)
      @ac1 = Factory(:activity, :user => @user, :project => @proj)
      @ac2 = Factory(:activity, :user => @user, :project => @proj)
      @ac3 = Factory(:activity, :user => @user2, :project => @proj)
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
      @user = Factory(:user)
      @proj = Factory(:project)
      @wu1 = Factory(:work_unit, :user => @user, :project => @proj, :hours => 3.0)      
    end
    it "should return a work unit associated with the specified project" do
      @user.completed_work_units_for(@proj).should include(@wu1)
    end               
    it "should return a work unit associated with a subproject" do
      @proj2 = Factory(:project, :parent => @proj)        
      @proj.reload.self_and_descendants.should include(@proj2)
      @wu2 = Factory(:work_unit, :user => @user, :project => @proj2, :hours => 3.0)      
      @user.completed_work_units_for(@proj).should include(@wu2)           
    end                                                          
    it "should not return a work unit for another user" do
      @other = Factory(:user)
      @wu3 = Factory(:work_unit, :user => @other, :project => @proj, :hours => 3.0)      
      @user.completed_work_units_for(@proj).should_not include(@wu3)
    end
    it "should not return a work unit for a project outside the heirarchy" do
      @proj3 = Factory(:project)
      @wu3 = Factory(:work_unit, :user => @user, :project => @proj3, :hours => 3.0)      
      @user.completed_work_units_for(@proj).should_not include(@wu3)
    end 
    it "should not include a work unit for a parent project" do
      @proj2 = Factory(:project, :parent => @proj)        
      @proj.reload.self_and_descendants.should include(@proj2)
      @user.completed_work_units_for(@proj2).should_not include(@wu1)
    end
  end  
  
  describe "activties_for" do
    before(:each) do
      @user = Factory(:user)
      @proj = Factory(:project)
      @ac1 = Factory(:activity, :user => @user, :project => @proj, :source => "github")      
    end

    it "should return an activity associated with the specified project" do
      @user.git_commits_for(@proj).should include(@ac1)
    end      

    it "should return an activity associated with a subproject" do
      @proj2 = Factory(:project, :parent => @proj)        
      @proj.reload.self_and_descendants.should include(@proj2)
      @ac2 = Factory(:activity, :user => @user, :project => @proj2, :source => "github")      
      @user.git_commits_for(@proj).should include(@ac2)           
    end  

    it "should not return a work unit for another user" do
      @other = Factory(:user)
      @ac3 = Factory(:activity, :user => @other, :project => @proj, :source => "github")      
      @user.git_commits_for(@proj).should_not include(@ac3)
    end
    it "should not return a work unit for a project outside the heirarchy" do
      @proj3 = Factory(:project)
      @ac3 = Factory(:activity, :user => @user, :project => @proj3, :source => "github")      
      @user.git_commits_for(@proj).should_not include(@ac3)
    end 
    it "should not include a work unit for a parent project" do
      @proj2 = Factory(:project, :parent => @proj)        
      @proj.reload.self_and_descendants.should include(@proj2)
      @user.git_commits_for(@proj2).should_not include(@ac1)
    end
  end 

  describe "hours_report_for" do
 
    it "should return a hash" do
      pending
      @user.hours_report_for(@proj).should be_a(Hash)                                
    end
  end
  
  
  
  
  
end
