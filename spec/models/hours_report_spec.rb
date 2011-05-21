require 'spec_helper'  
require 'hours_report'

describe HoursReport do
  before(:each) do
    @user       = Factory(:user)
    @user2      = Factory(:user)
    @proj       = Factory(:project, :name => "proj")
    @other_proj = Factory(:project, :name => "other")

    @subproj1 = Factory(:project, :parent => @proj, :name => "subproj1")
    @subproj2 = Factory(:project, :parent => @proj, :name => "subproj2")
    @ssubproj = Factory(:project, :parent => @subproj1, :name => "ssubproj")      

    @wu_1     = Factory(:work_unit, :user => @user, :project => @proj,     :hours => 0.1)
    @wu_2     = Factory(:work_unit, :user => @user, :project => @proj,     :hours => 0.2, :billable => false)
    @wu_2.update_attribute(:billable, false)
    @wu_2.should_not be_billable
    
    @s1_wu_1  = Factory(:work_unit, :user => @user,  :project => @subproj1, :hours => 0.4)
    @s1_wu_2  = Factory(:work_unit, :user => @user2, :project => @subproj1, :hours => 0.8)

    @s2_wu_1  = Factory(:work_unit, :user => @user2, :project => @subproj2, :hours => 1.6, :bill_id => 1)       
    @s2_wu_2  = Factory(:work_unit, :user => @user,  :project => @subproj2, :hours => 3.2)

    @ss_wu_1  = Factory(:work_unit, :user => @user,  :project => @ssubproj, :hours => 6.4)
    @ss_wu_2  = Factory(:work_unit, :user => @user,  :project => @ssubproj, :hours => 12.8)      

    # these two should never get picked up in the hours reports for @proj, 
    # so we should never see hundredth-hours in the  sums.
    @op_wu_1  = Factory(:work_unit, :user => @user, :project => @other_proj,     :hours => 0.01)
    @ou_wu_1  = Factory(:work_unit, :user => @user2, :project => @other_proj,     :hours => 0.02)
  end   
  
              
  describe "for a project" do
    it "should create an HoursReport successfully" do
      HoursReport.new(@proj)
    end    
    it "should return a hash for totals" do
      HoursReport.new(@proj).hours_row().should be_a(Hash)      
    end            
           
    describe "totals" do
      it "should include the correct total hours " do
        hr = HoursReport.new(@proj)
        hr.hours_row(:totals)[:total].should == 25.5              
      end
      it "should include the correct unbillable hours" do                   
        # debugger
        HoursReport.new(@proj).hours_row(:totals)[:unbillable].should == 0.2
      end
      it "should include the correct unbilled hours" do
        HoursReport.new(@proj).hours_row(:totals)[:unbilled].should == 23.7
      end      
    end  

    describe "by time period" do
      it "should return a today row with correct total" do
        HoursReport.new(@proj).by_time[:today][:total].should == 25.5        
      end
      
      it "should return a last seven row with correct total" do
        @ss_wu_2.update_attributes(:stop_time => Time.now - 9.days, :start_time => Time.now - 9.days - 16.hours)
        hr = HoursReport.new(@proj)
        # debugger
        hr.by_time[:last_7][:total].should == 12.7        
      end  
      
      it "should return a last thirty row with correct total" do
        @ss_wu_2.update_attributes(:stop_time => Time.now - 9.days, :start_time => Time.now - 9.days - 16.hours)
        @ss_wu_1.update_attributes(:stop_time => Time.now - 32.days, :start_time => Time.now - 32.days - 16.hours)
        hr = HoursReport.new(@proj).by_time[:last_30][:total].should == 19.1        
      end      
    end  
    
    describe "by project" do
      before(:each) do
        @hr = HoursReport.new(@proj)
      end
      it "should return a hash" do
        @hr.by_project.should be_a(Hash)         
      end          
      it "should have an entry for each project and subproject" do
        @hr.by_project.keys.should include(@proj)        
        @hr.by_project.keys.should include(@subproj1)        
        @hr.by_project.keys.should include(@subproj2)        
        @hr.by_project.keys.should include(@ssubproj)        
      end
      it "should have only the exclusive hours for the top project" do
        @hr.by_project[@proj][:total].should == 0.3                
        @hr.by_project[@proj][:unbillable].should == 0.2
        @hr.by_project[@proj][:unbilled].should == 0.1                                
      end       
      it "should have the exclusive hours for subproject 1" do   
        @hr.by_project[@subproj1][:total].should == 1.2                
        @hr.by_project[@subproj1][:unbillable].should == 0.0
        @hr.by_project[@subproj1][:unbilled].should == 1.2                                        
      end
      it "should have the exclusive hours for subproject 2" do
        @hr.by_project[@subproj2][:total].should == 4.8                
        @hr.by_project[@subproj2][:unbillable].should == 0.0
        @hr.by_project[@subproj2][:unbilled].should == 3.2                                        
      end    
      it "should have the exclusive hours for sub-subproject" do
        @hr.by_project[@ssubproj][:total].should == 19.2                
        @hr.by_project[@ssubproj][:unbillable].should == 0.0
        @hr.by_project[@ssubproj][:unbilled].should == 19.2                                        
      end      
    end    
    
  end             
  
  describe "for a project and a user" do
    describe "totals" do
      it "should include the correct total hours " do
        HoursReport.new(@proj, @user).hours_row(:totals)[:total].should == 23.1              
      end
      it "should include the correct unbillable hours" do                   
        HoursReport.new(@proj, @user).hours_row(:totals)[:unbillable].should == 0.2
      end
      it "should include the correct unbilled hours" do
        HoursReport.new(@proj, @user).hours_row(:totals)[:unbilled].should == 22.9
      end      
    end 
    
    describe "by time period" do
      it "should return a today row with correct total" do
        HoursReport.new(@proj, @user).by_time[:today][:total].should == 23.1        
      end
      
      it "should return a last seven row with correct total" do
        @ss_wu_2.update_attributes(:stop_time => Time.now - 9.days, :start_time => Time.now - 9.days - 16.hours)
        hr = HoursReport.new(@proj, @user).by_time[:last_7][:total].should == 10.3        
      end  
      
      it "should return a last thirty row with correct total" do
        @ss_wu_2.update_attributes(:stop_time => Time.now - 9.days, :start_time => Time.now - 9.days - 16.hours)
        @ss_wu_1.update_attributes(:stop_time => Time.now - 32.days, :start_time => Time.now - 32.days - 16.hours)
        hr = HoursReport.new(@proj, @user).by_time[:last_30][:total].should == 16.7        
      end      
    end  
    
    describe "by project" do
      before(:each) do
        @hr = HoursReport.new(@proj, @user)
      end
      it "should return a hash" do
        @hr.by_project.should be_a(Hash)         
      end          
      it "should have an entry for each project and subproject" do
        @hr.by_project.keys.should include(@proj)        
        @hr.by_project.keys.should include(@subproj1)        
        @hr.by_project.keys.should include(@subproj2)        
        @hr.by_project.keys.should include(@ssubproj)        
      end
      it "should have only the exclusive hours for the top project" do
        @hr.by_project[@proj][:total].should == 0.3                
        @hr.by_project[@proj][:unbillable].should == 0.2
        @hr.by_project[@proj][:unbilled].should == 0.1                                
      end       
      it "should have the exclusive hours for subproject 1" do   
        @hr.by_project[@subproj1][:total].should == 0.4                
        @hr.by_project[@subproj1][:unbillable].should == 0.0
        @hr.by_project[@subproj1][:unbilled].should == 0.4                                        
      end
      it "should have the exclusive hours for subproject 2" do
        @hr.by_project[@subproj2][:total].should == 3.2                
        @hr.by_project[@subproj2][:unbillable].should == 0.0
        @hr.by_project[@subproj2][:unbilled].should == 3.2                                        
      end    
      it "should have the exclusive hours for sub-subproject" do
        @hr.by_project[@ssubproj][:total].should == 19.2                
        @hr.by_project[@ssubproj][:unbillable].should == 0.0
        @hr.by_project[@ssubproj][:unbilled].should == 19.2                                        
      end      
    end    
    

  end
end