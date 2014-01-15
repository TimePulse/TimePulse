# == Schema Information
#
# Table name: work_units
#
#  id         :integer(4)      not null, primary key
#  project_id :integer(4)
#  user_id    :integer(4)
#  start_time :datetime
#  stop_time  :datetime
#  hours      :decimal(8, 2)
#  notes      :string(255)
#  invoice_id :integer(4)
#  bill_id    :integer(4)
#  created_at :datetime
#  updated_at :datetime
#  billable   :boolean(1)      default(TRUE)
#

require 'spec_helper'

describe WorkUnit do
  before(:each) do
    @work_unit = FactoryGirl.create(:work_unit)
  end


  describe "default behavior" do
    it "should override the start time with mass assignment" do
      time = Time.now - 5.days
      wu = WorkUnit.new(:start_time => time)
      wu.start_time.should be_within(1.second).of(time)
    end
  end

  describe "validations" do
    it "should be invalid without a start time" do
      FactoryGirl.build(:work_unit, :start_time => nil).should_not be_valid
    end
    it "should be invalid if stop time is specified but not hours" do
      FactoryGirl.build(:work_unit, :hours => nil).should_not be_valid
    end
    it "should not be valid if hours is specified but not stop time" do
      FactoryGirl.build(:work_unit, :stop_time => nil).should_not be_valid
    end

    # the user is not allowed to clock in on two tasks at once
    it "should be invalid if it's in_progress but the user already is clocked in" do
      @wu1 = FactoryGirl.create(:in_progress_work_unit)
      FactoryGirl.build(:in_progress_work_unit, :user => @wu1.user).should_not be_valid
    end

    it "should be invalid if the stop time is in the future" do
      FactoryGirl.build(:work_unit, :stop_time => Time.now + 1.minute).should_not be_valid
    end

    it "should be invalid if stop time is earlier than start time" do
      FactoryGirl.build(:work_unit, :start_time => Time.now, :stop_time => Time.now - 5.minutes).should_not be_valid
    end
    it "should be invalid if hours is negative" do
      FactoryGirl.build(:work_unit, :hours => -1).should_not be_valid
    end

    it "should be invalid if hours is greater than (stop time - start time)" do
      FactoryGirl.build(:work_unit, :hours => 99999).should_not be_valid
    end
  end

  describe "in_progress" do
    describe "named scope" do
      it "should not find a complete WU" do
        WorkUnit.in_progress.should_not include(@work_unit)
      end

      it "should find a WU with a start time but no hours or end time" do
        @wu2 = FactoryGirl.create(:work_unit, :start_time => Time.now-2.hours, :hours => nil, :stop_time => nil)
        WorkUnit.in_progress.should include(@wu2)
      end
    end
    describe "flag" do
      it "should be true for a WU with a start time but no hours or end time" do
        @wu2 = FactoryGirl.create(:work_unit, :start_time => Time.now-2.hours, :hours => nil, :stop_time => nil)
        @wu2.should be_in_progress
      end
      it "should be false for a WU with completed attributes" do
        FactoryGirl.create(:work_unit).should_not be_in_progress
      end
    end
  end

  describe "decimal_time_between" do
    it "should give 3.00 hours for an appropriate time" do
       @time = Time.zone.now
       WorkUnit.decimal_hours_between( @time - 3.hours, @time).should == 3.00
    end
    it "should give 3.50 hours for an appropriate time" do
       @time = Time.zone.now
       WorkUnit.decimal_hours_between( @time - 3.hours - 30.minutes, @time).should == 3.50
    end
    it "should round hours to 2 decimal places" do
      WorkUnit.decimal_hours_between(
        Time.parse("2010-05-27 19:49:24"),
        Time.parse("2010-05-27 19:58:49")).should == 0.16
    end
    it "should round hours to 2 decimal places" do
      WorkUnit.decimal_hours_between(
        Time.parse("2010-05-26 22:06:21"),
        Time.parse( "2010-05-26 23:58:31")).should == 1.87
    end
    it "should round hours to 2 decimal places" do
      WorkUnit.decimal_hours_between(
        Time.parse("2010-05-18 05:16:00"),
        Time.parse("2010-05-18 08:50:00")).should == 3.57
    end
    it "should round hours to 2 decimal places" do
      WorkUnit.decimal_hours_between(
        Time.parse("2010-05-26 19:58:56"),
        Time.parse("2010-05-26 20:00:32")).should == 0.03
    end
    it "should round a 20-minute period" do
      WorkUnit.decimal_hours_between(
        Time.parse("2010-05-26 4:00:00"),
        Time.parse("2010-05-26 4:20:00")).should == 0.33
    end

  end

  describe "validations" do
    it "should not allow a work unit with hours > (stop - start)" do
      @time = Time.zone.now
      FactoryGirl.build(:work_unit, :start_time => @time - 3.hours, :stop_time => @time, :hours => 3.01).should_not be_valid
    end
    it "should allow a work unit with hours = (stop - start)" do
      @time = Time.zone.now
      FactoryGirl.build(:work_unit, :start_time => @time - 3.hours, :stop_time => @time, :hours => 3.00).should be_valid
    end

    it "should not allow a blank stop_time when hours is set" do
      FactoryGirl.build(:work_unit, :stop_time => nil, :hours => 3.00).should_not be_valid
    end
  end

  describe "completed" do
    describe "named scope" do
      it "should find a complete WU" do
        WorkUnit.completed.should include(@work_unit)
      end

      it "should not find a WU with a start time but no hours or end time" do
        @wu2 = FactoryGirl.create(:work_unit, :start_time => Time.now - 2.hours, :hours => nil, :stop_time => nil)
        WorkUnit.completed.should_not include(@wu2)
      end
    end
    describe "flag" do
      it "should be true for a WU with a start time but no hours or end time" do
        @wu2 = FactoryGirl.create(:work_unit, :start_time => Time.now-2.hours, :hours => nil, :stop_time => nil)
        @wu2.should_not be_completed
      end
      it "should be true for a WU with completed attributes" do
        FactoryGirl.create(:work_unit).should be_completed
      end
    end
  end

  describe "truncate_hours" do
    it "should clamp excessive hours to the difference between start and stop time" do
      t = Time.now
      @wu2 = FactoryGirl.build(:work_unit, :start_time => t, :stop_time => t + 2.hours, :hours => 4.75)
      lambda { @wu2.truncate_hours! }.should change{ @wu2.hours }.from(4.75).to(2.0)
    end
    it "should not clamp excessive hours to the difference between start and stop time" do
      t = Time.now
      @wu2 = FactoryGirl.build(:work_unit, :start_time => t, :stop_time => t + 2.hours, :hours => 2)
      lambda { @wu2.truncate_hours! }.should_not change{ @wu2.hours }
    end
    it "should not change anything if there are no hours" do
      t = Time.now
      @wu2 = FactoryGirl.build(:work_unit, :start_time => t, :hours => nil)
      lambda { @wu2.truncate_hours! }.should_not change{ @wu2.hours }
    end
  end

  describe "billable" do
    it "should get set to true when the project is billable" do
      @proj = FactoryGirl.create(:project, :billable => true)
      FactoryGirl.create(:work_unit, :project => @proj).should be_billable
    end
    it "should get set to false when the project is not billable" do
      @proj = FactoryGirl.create(:project, :billable => false)
      @proj.should_not be_billable
      @proj.work_units.create().should_not be_billable
    end
  end

  describe "for_client" do
    before :each  do
      @client = FactoryGirl.create(:client)
      @project = FactoryGirl.create(:project, :billable => true, :client => @client)
    end
    it "should find a work unit for a client's project" do
      wu = FactoryGirl.create(:work_unit, :project => @project)
      WorkUnit.for_client(@client).should include(wu)
    end
    it "should find work units for two different projects" do
      proj2 = FactoryGirl.create(:project, :billable => true, :client => @client)
      wu1 = FactoryGirl.create(:work_unit, :project => @project)
      wu2 = FactoryGirl.create(:work_unit, :project => proj2)
      WorkUnit.for_client(@client).should include(wu1)
      WorkUnit.for_client(@client).should include(wu2)
    end
    it "should find work_units in a subproject only once" do
      proj2 = FactoryGirl.create(:project, :billable => true, :client => @client, :parent => @project)
      wu1 = FactoryGirl.create(:work_unit, :project => @project)
      wu2 = FactoryGirl.create(:work_unit, :project => proj2)
      WorkUnit.for_client(@client).should include(wu1)
      WorkUnit.for_client(@client).should include(wu2)
      WorkUnit.for_client(@client).count.should == 2
    end
    it "should not find a different client's work unit" do
      proj2 = FactoryGirl.create(:project, :billable => true, :client => FactoryGirl.create(:client))
      wu1 = FactoryGirl.create(:work_unit, :project => @project)
      wu2 = FactoryGirl.create(:work_unit, :project => proj2)
      WorkUnit.for_client(@client).should include(wu1)
      WorkUnit.for_client(@client).should_not include(wu2)
    end
  end
  
  describe "for_project" do
    before :each  do
      @client = FactoryGirl.create(:client)
      @project1 = FactoryGirl.create(:project,:name => "Project 1", :billable => true, 
                                    :client => @client)
      @project1a = FactoryGirl.create(:project,:name => "Project 1a", :billable => true, 
                                    :client => @client, :parent_id => @project1.id )
      @project1b = FactoryGirl.create(:project,:name => "Project 1b", :billable => true, 
                                    :client => @client, :parent_id => @project1.id )
      @project2 = FactoryGirl.create(:project,:name => "Project 2", :billable => true, 
                                    :client => @client)
      @project2a = FactoryGirl.create(:project,:name => "Project 2a", :billable => true, 
                                    :client => @client, :parent_id => @project2.id )
      @wu1 = FactoryGirl.create(:work_unit, :project => @project1)
      @wu1aa = FactoryGirl.create(:work_unit, :project => @project1a)
      @wu1ab = FactoryGirl.create(:work_unit, :project => @project1a)
      @wu1b = FactoryGirl.create(:work_unit, :project => @project1b)
      @wu2 = FactoryGirl.create(:work_unit, :project => @project2)
      @wu2a = FactoryGirl.create(:work_unit, :project => @project2a)
    end
    it "should find the work units for a specific project" do
      WorkUnit.for_project(@project1a).should include(@wu1aa)
      WorkUnit.for_project(@project1a).should include(@wu1ab)
      WorkUnit.for_project(@project1a).should == 2
    end
    it "should find work units for sub-projects of a parent" do
      WorkUnit.for_project(@project1).should include(@wu1)
      WorkUnit.for_project(@project1).should include(@wu1aa)
      WorkUnit.for_project(@project1).should include(@wu1b)
      WorkUnit.for_client(@client).should include(wu1)
      WorkUnit.for_client(@client).should include(wu2)
    end
    it "should find work_units in a subproject only once" do
      proj2 = FactoryGirl.create(:project, :billable => true, :client => @client, :parent => @project2)
      wu1 = FactoryGirl.create(:work_unit, :project => @project2)
      wu2 = FactoryGirl.create(:work_unit, :project => proj2)
      WorkUnit.for_client(@client).should include(wu1)
      WorkUnit.for_client(@client).should include(wu2)
      WorkUnit.for_client(@client).count.should == 2
    end
    it "should not find a different client's work unit" do
      proj2 = FactoryGirl.create(:project, :billable => true, :client => FactoryGirl.create(:client))
      wu1 = FactoryGirl.create(:work_unit, :project => @project2a)
      wu2 = FactoryGirl.create(:work_unit, :project => proj2)
      WorkUnit.for_client(@client).should include(wu1)
      WorkUnit.for_client(@client).should_not include(wu2)
    end
  end

  describe "this_week" do
    before(:each) do
      this_week = Time.zone.now.beginning_of_week
      last_week = this_week - 1.week
      @last_week_unit = FactoryGirl.create(:work_unit, :start_time => last_week, :stop_time => last_week + 2.hours, :hours => 2.0)
      @this_week_unit = FactoryGirl.create(:work_unit, :start_time => this_week, :stop_time => this_week + 2.hours, :hours => 2.0)
    end
    it "should find a WorkUnit created this week" do
      WorkUnit.this_week.should include(@this_week_unit)
    end
    it "should not find a WorkUnit created last week" do
      WorkUnit.this_week.should_not include(@last_week_unit)
    end
  end
end

