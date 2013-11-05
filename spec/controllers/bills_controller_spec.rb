require 'spec_helper'

describe BillsController do

  before(:each) do
    @bill = FactoryGirl.create(:bill, :due_on => Date.today + 1.week)
    @user = @bill.user
  end

  describe "as a normal user" do
    before(:each) do
      authenticate(@user)
    end
    it "should not be authenticated" do
      get :index
      verify_authorization_unsuccessful
    end
  end

  describe "as admin" do
    before(:each) do
      authenticate(:admin)
    end

    ########################################################################################
    #                                      GET INDEX
    ########################################################################################
    describe "GET index" do
      before(:each) do
        @unpaid_bills = [
            @bill,
            FactoryGirl.create(:bill, :paid_on => nil, :due_on => Date.today + 1.month),
            FactoryGirl.create(:bill, :paid_on => nil, :due_on => Date.today + 3.weeks)
        ].sort_by{|b| b.due_on}.reverse
        @paid_bills = [
          FactoryGirl.create(:bill, :paid_on => Date.today - 1.day),
          FactoryGirl.create(:bill, :paid_on => Date.today - 2.day)
        ].sort_by{|b| b.paid_on}.reverse
      end
      it "should paginate all unpaid bills as @unpaid_bills" do
        get :index
        assigns[:unpaid_bills].should == @unpaid_bills.paginate
      end
      it "should paginate all paid bills as @paid_bills" do
        get :index
        assigns[:paid_bills].should == @paid_bills.paginate
      end
      it "should be authorized" do
        get :index
        verify_authorization_successful
      end
    end

    ########################################################################################
    #                                      GET SHOW
    ########################################################################################
    describe "responding to GET show" do
      it "should expose the requested bill as @bill" do
        get :show, :id => @bill.id
        assigns[:bill].should == @bill
      end
      it "should be authorized" do
        get :show, :id => @bill.id
        verify_authorization_successful
      end
    end

    ########################################################################################
    #                                      GET NEW
    ########################################################################################
    describe "responding to GET new" do
      it "should expose a new bill as @bill" do
        get :new
        assigns[:bill].should be_a(Bill)
        assigns[:bill].should be_new_record
      end
      it "should be authorized" do
        get :new
        verify_authorization_successful
      end
      describe "user selection" do
        before :each  do
          @users = [
            FactoryGirl.create(:user, :name => 'John ABC'),
            FactoryGirl.create(:user, :name => 'John DEF'),
            FactoryGirl.create(:user, :name => 'John GHI')
          ]
        end
        it "should assign a list of users" do
          get :new
          assigns[:users].should == User.find(:all, :order => "name ASC")
        end

        describe "when a specific user is specified" do
          before :each  do
            @user = @users[0]
            client = FactoryGirl.create(:client)
            @project = FactoryGirl.create(:project, :client => client)
          end

          it "should assign an individual user if user_id is specified" do
            get :new, :user_id => @users[0].id
            assigns[:user].should == @users[0]
          end

          describe "the list of work units" do
            before :each  do
              @wu1 = FactoryGirl.create(:work_unit, :project => @project, :billable => true, :user => @user)
            end
            it "should all belong to that user" do
              get :new, :user_id => @users[0].id
              assigns[:work_units].each do |wu|
                wu.user.should == @users[0]
              end
            end

            it "should include billable unbilled work units" do
              @wu2 = FactoryGirl.create(:work_unit, :project => @project, :billable => true, :user => @user)
              get :new, :user_id => @users[0].id
              assigns[:work_units].should include(@wu1)
              assigns[:work_units].should include(@wu2)
            end

            it "should not include unbillable work units" do
              @wu2 = FactoryGirl.create(:work_unit, :project => @project)
              @wu2.update_attribute(:billable, false)
              get :new, :user_id => @users[0].id
              assigns[:work_units].should_not include(@wu2)
            end

            it "should not include billed work units" do
              billed = [
                FactoryGirl.create(:work_unit, :project => @project, :billable => true, :user => @user),
                FactoryGirl.create(:work_unit, :project => @project, :billable => true, :user => @user)
              ]
              FactoryGirl.create(:bill, :work_units => billed)
              get :new, :user_id => @users[0].id
              assigns[:work_units].should_not include(billed[0])
              assigns[:work_units].should_not include(billed[1])
            end

            it "should not include uncompleted work units" do
              @wu2 = FactoryGirl.create(:work_unit, :project => @project, :stop_time => nil, :hours => nil)
              get :new, :user_id => @users[0].id
              assigns[:work_units].should_not include(@wu2)
            end

            it "should not include work units for another user" do
              @wu2 = FactoryGirl.create(:work_unit, :project => @project, :billable => true, :user => @users[1])
              get :new, :user_id => @users[0].id
              assigns[:work_units].should     include(@wu1)
              assigns[:work_units].should_not include(@wu2)
            end
          end
        end
      end
    end

    ########################################################################################
    #                                      GET EDIT
    ########################################################################################
    describe "responding to GET edit" do
      it "should expose the requested bill as @bill" do
        get :edit, :id => @bill.id
        assigns[:bill].should == @bill
      end
      it "should be authorized" do
        get :edit, :id => @bill.id
        verify_authorization_successful
      end
    end

    ########################################################################################
    #                                      POST CREATE
    ########################################################################################
    describe "responding to POST create" do

      describe "with valid params" do
        before do
          @user = FactoryGirl.create(:user)
          @valid_create_params = {
            :due_on => Date.today,
            :user_id => @user.id,
            :notes => "value for notes"
          }
        end

        it "should be authorized" do
          post :create, :bill => @valid_create_params
          verify_authorization_successful
        end
        it "should create a new bill in the database" do
          lambda do
            post :create, :bill => @valid_create_params
          end.should change(Bill, :count).by(1)
        end

        it "should expose a saved bill as @bill" do
          post :create, :bill => @valid_create_params
          assigns[:bill].should be_a(Bill)
        end

        it "should save the newly created bill as @bill" do
          post :create, :bill => @valid_create_params
          assigns[:bill].should_not be_new_record
        end

        it "should redirect to the created bill" do
          post :create, :bill => @valid_create_params
          new_bill = assigns[:bill]
          response.should redirect_to(bill_url(new_bill))
        end

        describe "with specified work unit ids" do
          before :each  do
            @proj = FactoryGirl.create(:project, :client => @client)
            @wu1 = FactoryGirl.create(:work_unit, :project => @proj)
            @wu2 = FactoryGirl.create(:work_unit, :project => @proj)
            @wu3 = FactoryGirl.create(:work_unit, :project => @proj)
          end
          it "should include specified work units in the bill" do
            post :create, :bill => @valid_create_params.merge!({ :work_unit_ids => {
              @wu1.id => "1",
              @wu2.id => "1"
            } })
            assigns[:bill].work_units.should include(@wu1)
            assigns[:bill].work_units.should include(@wu2)
          end
          it "should exclude ommitted work units in the bill" do
            post :create, :bill => @valid_create_params.merge!( :work_unit_ids => {
              @wu1.id => "1",
              @wu2.id => "0"
            } )
            assigns[:bill].work_units.should include(@wu1)
            assigns[:bill].work_units.should_not include(@wu2)
          end
        end
      end

      describe "with invalid params" do
        before do
          @invalid_create_params = {
            :due_on => Date.today,
            :user_id => nil,
            :notes => "value for notes"
          }
        end

        it "should not create a new bill in the database" do
          lambda do
            post :create, :bill => @invalid_create_params
          end.should_not change(Bill, :count)
        end

        it "should expose a newly created bill as @bill" do
          post :create, :bill => @invalid_create_params
          assigns(:bill).should be_a(Bill)
        end

        it "should expose an unsaved bill as @bill" do
          post :create, :bill => @invalid_create_params
          assigns(:bill).should be_new_record
        end

        it "should re-render the 'new' template" do
          post :create, :bill => @invalid_create_params
          response.should render_template('new')
        end
      end
    end

    ########################################################################################
    #                                      PUT UPDATE
    ########################################################################################
    describe "responding to PUT update" do

      describe "with valid params" do
        before do
          @valid_update_params = {
            :notes => "different notes."
          }
        end

        it "should be authorized" do
          put :update, :id => @bill.id, :bill => @valid_update_params
          verify_authorization_successful
        end

        it "should update the requested bill in the database" do
          lambda do
            put :update, :id => @bill.id, :bill => @valid_update_params
          end.should change{ @bill.reload.notes }.to("different notes.")
        end

        it "should expose the requested bill as @bill" do
          put :update, :id => @bill.id, :bill => @valid_update_params
          assigns(:bill).should == @bill
        end

        it "should redirect to the bill" do
          put :update, :id => @bill.id, :bill => @valid_update_params
          response.should redirect_to(bill_url(@bill))
        end
      end

      describe "with invalid params" do
        before do
          @invalid_update_params = {
            :user_id => nil
          }
        end

        it "should not change the bill in the database" do
          lambda do
            put :update, :id => @bill.id, :bill => @invalid_update_params
          end.should_not change{ @bill.reload }
        end

        it "should expose the bill as @bill" do
          put :update, :id => @bill.id, :bill => @invalid_update_params
          assigns(:bill).should == @bill
        end

        it "should re-render the 'edit' template" do
          put :update, :id => @bill.id, :bill => @invalid_update_params
          response.should render_template('edit')
        end
      end
    end


    ########################################################################################
    #                                      DELETE DESTROY
    ########################################################################################
    describe "DELETE destroy" do
      it "should be authorized" do
        delete :destroy, :id => @bill.id
        verify_authorization_successful
      end

      it "should reduce bill count by one" do
        lambda do
          delete :destroy, :id => @bill.id
        end.should change(Bill, :count).by(-1)
      end

      it "should make the bills unfindable in the database" do
        delete :destroy, :id => @bill.id
        lambda{ Bill.find(@bill.id)}.should raise_error(ActiveRecord::RecordNotFound)
      end

      it "should redirect to the bills list" do
        delete :destroy, :id => @bill.id
        response.should redirect_to(bills_url)
      end
    end

  end


end
