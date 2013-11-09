require 'spec_helper'

describe ClockTimeController do
  before(:each) do
    @user = authenticate(:user)
    @project = FactoryGirl.create(:task)
  end

  describe "POST 'create'" do
    describe "with valid parameters" do
      it "should be authorized" do
        post :create, :id => @project.id
        verify_authorization_successful
      end
      it "should succeed" do
        post :create, :id => @project.id
        response.should redirect_to(root_path)
      end
      it "should assign a work unit for the current user" do
        post :create, :id => @project.id
        assigns[:work_unit].should be_a(WorkUnit)
        assigns[:work_unit].user.should == @user
      end
      it "should assign a work unit for the specified project" do
        post :create, :id => @project.id
        assigns[:work_unit].project.should == @project
      end
      it "should assign a work unit starting at the current time" do
        post :create, :id => @project.id
        assigns[:work_unit].start_time.should be_within(10.seconds).of(Time.now)
      end

      it "should set my current project to the project id" do
        post :create, :id => @project.id
        controller.current_user.current_project.should == @project
        controller.current_user.reload.current_project.should == @project

        #@user.reload
        #@user.current_project.should == @project
      end

      it "should assign a work unit with nil hours" do
        post :create, :id => @project.id
        assigns[:work_unit].hours.should be_nil
      end
      it "should assign a work unit with nil end_time" do
        post :create, :id => @project.id
        assigns[:work_unit].stop_time.should be_nil
      end
      it "should save the work unit" do
        post :create, :id => @project.id
        assigns[:work_unit].should_not be_new_record
      end
      it "should cause the user to become clocked in" do
        lambda do
          post :create, :id => @project.id
        end.should change{ @user.reload.clocked_in? }.from(false).to(true)
      end

      describe "with AJAX" do
        before(:each) { @request.env['HTTP_ACCEPT'] = 'application/javascript' }
        it "should respond with javascript" do
          post :create, :id => @project.id
          response.headers['Content-Type'].should =~ /text\/javascript/
        end
      end


      describe "on an unbillable project" do
        it "should succesfully clock in" do
          @unbillable = FactoryGirl.create(:project, :billable => false)
          lambda do
            post :create, :id => @unbillable.id
          end.should change(WorkUnit, :count).by(1)
          @user.should be_clocked_in
        end

        it "should create a work unit that's in progress but not billable" do
          @unbillable = FactoryGirl.create(:project, :billable => false)
          post :create, :id => @unbillable.id
          assigns[:work_unit].should be_in_progress
          assigns[:work_unit].should_not be_billable
        end
      end
    end
  end

  describe "DELETE 'destroy'" do
    describe "with invalid conditions - manual hours too high", :pending => "Not implemented yet." do
      # TODO:  Right now, the app handles invalid hours submissions by just truncating hours when
      # the WU is clocked out.   So if you clock in for 6 minutes and manually enter 10 hours, you will
      # silently end up with a work unit for 0.10 hours.  Probably ought to be changed in the future, and
      # these specs are here for that.
      before(:each) do
        @start_time = Time.zone.now - 6.hours
        @wu = FactoryGirl.create(:in_progress_work_unit, :user => @user, :project => @project, :start_time => @start_time)
        @wu.reload   # to clear the microseconds from @wu.start_time
      end
      it "should not mark the unit completed" do
        lambda do
          delete :destroy, :id => @wu.id, :work_unit => { :hours => '7.0' }
        end.should_not change{ @wu.reload.completed? }.from(false)
      end
      it "should not set the hours" do
        delete :destroy, :id => @wu.id, :work_unit => { :hours => '7.0' }
        @wu.reload.hours.should be_blank
      end
    end


    describe "under valid conditions" do
      before(:each) do
        @start_time = Time.zone.now - 6.hours
        @wu = FactoryGirl.create(:in_progress_work_unit, :user => @user, :project => @project, :start_time => @start_time)
        @wu.reload   # to clear the microseconds from @wu.start_time
      end

      it "should find the current user's in-progress work unit" do
        delete :destroy
        assigns[:work_unit].should == @wu
      end

      it "should cause the user to become clocked out" do
        lambda do
          delete :destroy
        end.should change{ @user.clocked_in? }.from(true).to(false)
      end

      describe "with AJAX" do
        render_views

        before(:each) { @request.env['HTTP_ACCEPT'] = 'application/javascript' }
        it "should respond with javascript" do
          delete :destroy
          response.headers['Content-Type'].should =~ /text\/javascript/
        end

        it "should show the user as not clocked in" do
          delete :destroy
          response.body.should =~ /not clocked in/
        end
      end

      describe "without any parameters supplied" do
        it "should set the end time of the work unit to now" do
          delete :destroy
          assigns[:work_unit].reload.stop_time.should be_within(10.seconds).of(Time.now)
        end
      end
      describe "with hours supplied" do

        describe "in decimal" do
          it "should set the hours equal to the param" do
            delete :destroy, :work_unit => { :hours => 3.5, :stop_time => (@wu.start_time + 4.hours)  }
            assigns[:work_unit].reload.hours.should == 3.5
          end
          it "should set hours equal to the param if stop time is an empty string" do
            delete :destroy, :work_unit => { :hours => 3.75, :stop_time => ' '  }
            assigns[:work_unit].reload.hours.should == 3.75
          end
          it "should set the stop time to now if the param is 'now'" do
            delete :destroy, :work_unit => { :hours => 3.75, :stop_time => 'now'  }
            assigns[:work_unit].reload.stop_time.should be_within(10.seconds).of(Time.zone.now)
          end
          it "should truncate hours that don't fit between start_time and stop_time" do
            delete :destroy, :work_unit => { :hours => 3.5, :stop_time => (@wu.start_time + 2.hours) }
            @wu.reload.hours.should == 2.0
          end
        end

        describe "in HH:MM" do
          it "should set the hours equal to the param" do
            delete :destroy, :work_unit => { :hours => "3:30", :stop_time => (@wu.start_time + 4.hours)  }
            assigns[:work_unit].reload.hours.should == 3.5
          end
          it "should set hours equal to the param if stop time is an empty string" do
            delete :destroy, :work_unit => { :hours => "3:45", :stop_time => ' '  }
            assigns[:work_unit].reload.hours.should == 3.75
          end
          it "should set the stop time to now if the param is 'now'" do
            delete :destroy, :work_unit => { :hours => "3:45", :stop_time => 'now'  }
            assigns[:work_unit].reload.stop_time.should be_within(10.seconds).of(Time.zone.now)
          end
          it "should truncate hours that don't fit between start_time and stop_time" do
            delete :destroy, :work_unit => { :hours => "3:30", :stop_time => (@wu.start_time + 2.hours) }
            @wu.reload.hours.should == 2.0
          end
        end

      end


    end
  end
end
