require 'spec_helper'

describe WorkUnitsController do

  describe "as admin" do
    before(:each) do
      @user = authenticate(:admin)
      @work_unit = Factory(:work_unit)
    end

    let! :project do Factory(:project) end

    ########################################################################################
    #                                      GET INDEX
    ########################################################################################
    describe "GET index" do
      it "should expose all work_units as @work_units" do
        get :index
        assigns[:work_units].should == [@work_unit]
      end
    end

    ########################################################################################
    #                                      GET SHOW
    ########################################################################################
    describe "responding to GET show" do
      it "should expose the requested work_unit as @work_unit" do
        get :show, :id => @work_unit.id
        assigns[:work_unit].should == @work_unit
      end
    end

    ########################################################################################
    #                                      GET NEW
    ########################################################################################
    describe "responding to GET new" do
      it "should expose a new work_unit as @work_unit" do
        get :new
        assigns[:work_unit].should be_a(WorkUnit)
        assigns[:work_unit].should be_new_record
      end
    end

    ########################################################################################
    #                                      GET EDIT
    ########################################################################################
    describe "responding to GET edit" do
      it "should expose the requested work_unit as @work_unit" do
        get :edit, :id => @work_unit.id
        assigns[:work_unit].should == @work_unit
      end
    end

    ########################################################################################
    #                                      POST CREATE
    ########################################################################################
    describe "responding to POST create" do
      describe "for a work unit without a start time" do
        before do
          post :create, :work_unit => { :project_id => project.id }
        end

        it "should assign an invalid work unit" do
          assigns[:work_unit].should_not be_valid
        end
      end

      describe "for a work unit with a start time but blank stop time" do
        before do
          @start = Time.now - 2 * 60 * 60
          @time = Time.now
          post :create, :work_unit => { :project_id => project.id,
            :start_time => @start, :calculate => true, :hours => '2'
          }
        end

        it "should succeed" do
          response.should be_redirect
        end

        it "should create a work unit with a real stop time" do
          assigns[:work_unit].stop_time.should be_within(1.second).of(@time)
        end
      end

      describe "with start and stop times as strings" do
        it "should description" do
          @time = Time.now
          @start = Time.now - 2 * 60 * 60
          @stop = @start + 1.5 * 3600
          post :create, :work_unit => { :project_id => project.id,
            :start_time => @start.to_s(:long), :stop_time => @stop.to_s(:long), :calculate => true
          }
          assigns[:work_unit].hours.should == 1.5
        end
      end

      describe "with a 20-minute work unit" do
        before :each do
          @start = Time.parse("May 5, 2010 4:00").to_s(:date_and_time)
          @stop  = Time.parse("May 5, 2010 4:20").to_s(:date_and_time)
        end
        it "should create a work unit" do
          lambda do
            post :create, :work_unit => { :project_id => project.id,
              :start_time => @start, :stop_time => @stop, :calculate => true
            }
          end.should change(WorkUnit, :count).by(1)
          assigns[:work_unit].hours.should be_within(0.003).of(0.33)
        end
      end

      describe "for a work unit with a 'calc' hours" do
        before do
          @time = Time.now
          @start = Time.now - 2 * 60 * 60
          @stop = @start + 1.5 * 3600
          post :create, :work_unit => { :project_id => project.id,
            :start_time => @start, :stop_time => @stop, :calculate => true
          }
        end

        it "should create a work unit with hours" do
          assigns[:work_unit].hours.should == 1.5
        end
      end

      describe "with valid params" do
        before do
          @valid_create_params = {
            :project_id => project.id,
            :start_time => Time.now
          }
        end

        it "should create a new work_unit in the database" do
          lambda do
            post :create, :work_unit => @valid_create_params
          end.should change(WorkUnit, :count).by(1)
        end

        it "should expose a saved work_unit as @work_unit" do
          post :create, :work_unit => @valid_create_params
          assigns[:work_unit].should be_a(WorkUnit)
        end

        it "should save the newly created work_unit as @work_unit" do
          post :create, :work_unit => @valid_create_params
          assigns[:work_unit].should_not be_new_record
        end

        it "should redirect to the created work_unit" do
          post :create, :work_unit => @valid_create_params
          new_work_unit = assigns[:work_unit]
          response.should redirect_to(work_unit_url(new_work_unit))
        end

        it "should set the work_unit's user to the current user" do
          post :create, :work_unit => @valid_create_params
          assigns[:work_unit].user.should == @user
        end
        describe "and hours in HH:MM format" do
          it "should set the hours correctli" do
            post :create, :work_unit => @valid_create_params.merge!(:hours => "4:15")
            assigns[:work_unit].hours.should == 4.25
          end
        end

        describe "and JS accept type" do
          before do
            request.env['HTTP_ACCEPT'] = 'application/javascript'
            @user.current_project = project
            @user.save
          end
          it "should set the work units list" do
            post :create, :work_unit => @valid_create_params
            assigns(:work_units).should ==  @user.work_units_for(@user.current_project).order("stop_time DESC").paginate(:per_page => 10, :page => 1) 
          end
        end
      end

      describe "with invalid params" do
        def invalid_create_params
          #invalid because work units require a project
          @valid_create_params = {
            :project_id => nil,
            :start_time => Time.now
          }
        end

        it "should not create a new work_unit in the database" do
          lambda do
            post :create, :work_unit => invalid_create_params
          end.should_not change(WorkUnit, :count)
        end

        it "should expose a newly created work_unit as @work_unit" do
          post :create, :work_unit => invalid_create_params
          assigns(:work_unit).should be_a(WorkUnit)
        end

        it "should expose an unsaved work_unit as @work_unit" do
          post :create, :work_unit => invalid_create_params
          assigns(:work_unit).should be_new_record
        end

        it "should re-render the 'new' template" do
          post :create, :work_unit => invalid_create_params
          response.should render_template('new')
        end
      end
    end

    ########################################################################################
    #                                      PUT UPDATE
    ########################################################################################
    describe "responding to PUT update" do
      describe "for a work unit with a start time and calculate = true" do
        before do
          @start = Time.now - 2.5.hours
        end

        it "should redirect " do
          put :update, :id => @work_unit.id, :work_unit => {:project_id => project.id,
            :start_time => @start, :calculate => "true", :hours => '2'
          }
          response.should be_redirect
        end

        it "should create a work unit with a real stop time" do
          put :update, :id => @work_unit.id, :work_unit => {:project_id => project.id,
            :start_time => @start, :calculate => "true", :hours => '2'
          }
          assigns[:work_unit].stop_time.should be_within(90.seconds).of(Time.now.utc)
        end
      end

      describe "for a work unit with no hours but calculate = true" do
        before do
          @time = Time.zone.now
          start = @time - 2.hours
          stop = start + 1.5.hours
          put :update, :id => @work_unit.id, :work_unit => {
            :project_id => project.id,
            :start_time => start,
            :stop_time => stop,
            :hours => nil, :calculate => "true"
          }
        end

        it "should expose the requested work_unit as @work_unit" do
          assigns(:work_unit).should == @work_unit
        end

        it "should create a work unit with hours" do
          assigns[:work_unit].hours.should be_within(0.001).of(1.5)
        end
      end

      describe "with valid params" do
        def valid_update_params
          { :notes => "A comment here" }
        end

        it "should update the requested work_unit in the database" do
          lambda do
            put :update, :id => @work_unit.id, :work_unit => valid_update_params
          end.should change{ @work_unit.reload.notes }.to("A comment here")
        end

        it "should expose the requested work_unit as @work_unit" do
          put :update, :id => @work_unit.id, :work_unit => valid_update_params
          assigns(:work_unit).should == @work_unit
        end

        it "should redirect to the work_unit" do
          put :update, :id => @work_unit.id, :work_unit => valid_update_params
          response.should redirect_to(work_unit_url(@work_unit))
        end
        describe "hours in HH:MM" do
          it "should update hours correctly" do
            lambda do
              put :update, :id => @work_unit.id, :work_unit => valid_update_params.merge!( :hours => "3:45" )
            end.should change{ @work_unit.reload.hours }.to(3.75)
          end
        end

      end

      describe "with invalid params" do
        def invalid_update_params
          { :project_id => nil }
        end

        it "should not change the work_unit in the database" do
          lambda do
            put :update, :id => @work_unit.id, :work_unit => invalid_update_params
          end.should_not change{ @work_unit.reload }
        end

        it "should expose the work_unit as @work_unit" do
          put :update, :id => @work_unit.id, :work_unit => invalid_update_params
          assigns(:work_unit).should == @work_unit
        end

        it "should re-render the 'edit' template" do
          put :update, :id => @work_unit.id, :work_unit => invalid_update_params
          response.should render_template('edit')
        end
      end
    end


    ########################################################################################
    #                                      DELETE DESTROY
    ########################################################################################
    describe "DELETE destroy" do

      it "should reduce work_unit count by one" do
        lambda do
          delete :destroy, :id => @work_unit.id
        end.should change(WorkUnit, :count).by(-1)
      end

      it "should make the work_units unfindable in the database" do
        delete :destroy, :id => @work_unit.id
        lambda{ WorkUnit.find(@work_unit.id)}.should raise_error(ActiveRecord::RecordNotFound)
      end

      it "should redirect to the work_units list" do
        delete :destroy, :id => @work_unit.id
        response.should redirect_back
      end

    end
  end
end


