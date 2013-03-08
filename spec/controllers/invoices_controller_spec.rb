require 'spec_helper'

describe InvoicesController do

  
  describe "as an admin" do
    before(:each) do
      authenticate(:admin)
    end
    ########################################################################################
    #                                      GET INDEX
    ########################################################################################
    describe "GET index" do
      before(:each) do
        @invoice = Factory(:invoice)   
        @client = @invoice.client
        
        @unpaid_invoices = [
            @invoice,
            Factory(:invoice, :paid_on => nil),
            Factory(:invoice, :paid_on => nil)
        ]
        @paid_invoices = [
          Factory(:invoice, :paid_on => Date.today - 1.day),
          Factory(:invoice, :paid_on => Date.today - 1.day)
        ]  
      end
      it "should paginate all unpaid invoices as @unpaid_invoices" do
        get :index
        assigns[:unpaid_invoices].should include(*(@unpaid_invoices.paginate))
      end  
      it "should paginate all paid invoices as @paid_invoices" do
        get :index
        assigns[:paid_invoices].should == @paid_invoices.sort_by(&:created_at).paginate
      end        
      it "should be authorized" do
        get :index
        response.should_not redirect_to(default_unauthorized_path)       
      end
    end

    ########################################################################################
    #                                      GET SHOW
    ########################################################################################
    describe "responding to GET show" do
      before :each  do
        @invoice = Factory(:invoice)   
        @client = @invoice.client        
      end
      it "should expose the requested invoice as @invoice" do
        get :show, :id => @invoice.id
        assigns[:invoice].should == @invoice
      end           
      it "should be authorized" do
        get :show, :id => @invoice.id
        response.should_not redirect_to(default_unauthorized_path)       
      end
    end

    ########################################################################################
    #                                      GET NEW
    ########################################################################################
    describe "responding to GET new" do  
      it "should expose a new invoice as @invoice" do
        get :new
        assigns[:invoice].should be_a(Invoice)
        assigns[:invoice].should be_new_record
      end    
      it "should be authorized" do
        get :new
        response.should_not redirect_to(default_unauthorized_path)       
      end
      describe "client selection" do
        before :each  do
          @clients = [ 
            Factory(:client, :abbreviation => 'ABC'), 
            Factory(:client, :abbreviation => 'DEF' ),             
            Factory(:client, :abbreviation => 'XYZ' ) 
          ]
        end        
        it "should assign a list of clients" do
          get :new
          assigns[:clients].should == Client.find(:all, :order => "abbreviation ASC")
        end        
        
        describe "when a specific client is specified" do
          before :each  do
            @client = @clients[0]
            @project = Factory(:project, :client => @client)
          end

          it "should assign an individual client if client_id is specified" do
            get :new, :client_id => @clients[0].id
            assigns[:client].should == @clients[0]
          end

          describe "the list of work units" do
            before :each  do
              @wu1 = Factory(:work_unit, :project => @project, :billable => true)              
            end
            it "should all belong to that client" do
              get :new, :client_id => @clients[0].id
              assigns[:work_units].each do |wu|
                wu.project.client.should == @clients[0]
              end
            end
            
            it "should include billable uninvoiced work units" do
              @wu2 = Factory(:work_unit, :project => @project, :billable => true)              
              get :new, :client_id => @clients[0].id
              assigns[:work_units].should include(@wu1)
              assigns[:work_units].should include(@wu2)              
            end  
              
            it "should not include unbillable work units" do
              @wu2 = Factory(:work_unit, :project => @project)
              @wu2.update_attribute(:billable, false)
              get :new, :client_id => @clients[0].id
              assigns[:work_units].should_not include(@wu2)
            end          
            
            it "should not include invoiced work units" do
              invoiced = [ 
                Factory(:work_unit, :project => @project, :billable => true),
                Factory(:work_unit, :project => @project, :billable => true)                              
              ]
              Factory(:invoice, :work_units => invoiced)                                                       
              get :new, :client_id => @clients[0].id
              assigns[:work_units].should_not include(invoiced[0])
              assigns[:work_units].should_not include(invoiced[1])                          
            end
            
            it "should not include uncompleted work units" do
              @wu2 = Factory(:work_unit, :project => @project, :stop_time => nil, :hours => nil)
              get :new, :client_id => @clients[0].id
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
      before :each  do
        @invoice = Factory(:invoice)   
        @client = @invoice.client
      end
      it "should expose the requested invoice as @invoice" do
        get :edit, :id => @invoice.id
        assigns[:invoice].should == @invoice
      end            
      it "should be authorized" do
        get :edit, :id => @invoice.id   
        response.should_not redirect_to(default_unauthorized_path)       
      end
    end

    ########################################################################################
    #                                      POST CREATE
    ########################################################################################
    describe "responding to POST create" do
      before :each  do
        @client = Factory(:client)
      end  
      describe "with valid params" do
        before do
          @valid_create_params = {    
            :due_on => Date.today,
            :client_id => @client.id,
            :notes => "value for notes"
          }
        end
                   
        it "should be authorized" do
          post :create, :invoice => @valid_create_params
          response.should_not redirect_to(default_unauthorized_path)
        end
        it "should create a new invoice in the database" do
          lambda do 
            post :create, :invoice => @valid_create_params
          end.should change(Invoice, :count).by(1)
        end

        it "should expose a saved invoice as @invoice" do
          post :create, :invoice => @valid_create_params
          assigns[:invoice].should be_a(Invoice)
        end

        it "should save the newly created invoice as @invoice" do
          post :create, :invoice => @valid_create_params
          assigns[:invoice].should_not be_new_record
        end

        it "should redirect to the created invoice" do
          post :create, :invoice => @valid_create_params
          new_invoice = assigns[:invoice]
          response.should redirect_to(invoice_url(new_invoice))
        end    
        
        describe "with specified work unit ids" do
          before :each  do
            @proj = Factory(:project, :client => @client)
            @wu1 = Factory(:work_unit, :project => @proj)
            @wu2 = Factory(:work_unit, :project => @proj)
            @wu3 = Factory(:work_unit, :project => @proj)
          end
          it "should expose a saved invoice as @invoice" do
            post :create, :invoice => @valid_create_params
            assigns[:invoice].should be_a(Invoice)
          end

          it "should save the newly created invoice as @invoice" do
            post :create, :invoice => @valid_create_params
            assigns[:invoice].should_not be_new_record
          end

          it "should redirect to the created invoice" do
            post :create, :invoice => @valid_create_params
            new_invoice = assigns[:invoice]
            response.should redirect_to(invoice_url(new_invoice))
          end    
          it "should include specified work units in the invoice" do
            post :create, :invoice => @valid_create_params.merge!({ :work_unit_ids => {
              "#{@wu1.id}" => "1",
              "#{@wu2.id}" => "1"
            } })
            assigns[:invoice].work_units.should include(@wu1)
            assigns[:invoice].work_units.should include(@wu2)
          end
          it "should exclude ommitted work units in the invoice" do
            post :create, :invoice => @valid_create_params.merge!( :work_unit_ids => {
              @wu1.id => "1",
              @wu2.id => "0"
            } )
            assigns[:invoice].work_units.should include(@wu1)
            assigns[:invoice].work_units.should_not include(@wu2)
          end
          
        end  
      end

      describe "with invalid params" do
        before do
          @invalid_create_params = {
            :due_on => Date.today,
            :client_id => nil,
            :notes => "value for notes"            
          } 
        end

        it "should not create a new invoice in the database" do
          lambda do 
            post :create, :invoice => @invalid_create_params
          end.should_not change(Invoice, :count)
        end      

        it "should expose a newly created invoice as @invoice" do
          post :create, :invoice => @invalid_create_params
          assigns(:invoice).should be_a(Invoice)
        end

        it "should expose an unsaved invoice as @invoice" do
          post :create, :invoice => @invalid_create_params
          assigns(:invoice).should be_new_record
        end

        it "should re-render the 'new' template" do
          post :create, :invoice => @invalid_create_params
          response.should render_template('new')
        end      
      end    
    end

    ########################################################################################
    #                                      PUT UPDATE
    ########################################################################################
    describe "responding to PUT update" do
      before :each  do
        @invoice = Factory(:invoice)   
        @client = @invoice.client        
      end
      describe "with valid params" do
        before do
          @valid_update_params = {
            :notes => "different notes."              
          } 
        end
               
        it "should be authorized" do
          put :update, :id => @invoice.id, :invoice => @valid_update_params   
          response.should_not redirect_to(default_unauthorized_path)
        end
        it "should update the requested invoice in the database" do          
          lambda do
            put :update, :id => @invoice.id, :invoice => @valid_update_params
          end.should change{ @invoice.reload.notes }.to("different notes.")
        end

        it "should expose the requested invoice as @invoice" do
          put :update, :id => @invoice.id, :invoice => @valid_update_params
          assigns(:invoice).should == @invoice
        end

        it "should redirect to the invoice" do
          put :update, :id => @invoice.id, :invoice => @valid_update_params
          response.should redirect_to(invoice_url(@invoice))
        end
      end

      describe "with invalid params" do
        before do
          @invalid_update_params = {
            :client_id => nil
          } 
        end

        it "should not change the invoice in the database" do
          lambda do 
            put :update, :id => @invoice.id, :invoice => @invalid_update_params
          end.should_not change{ @invoice.reload }
        end

        it "should expose the invoice as @invoice" do
          put :update, :id => @invoice.id, :invoice => @invalid_update_params
          assigns(:invoice).should == @invoice
        end

        it "should re-render the 'edit' template" do
          put :update, :id => @invoice.id, :invoice => @invalid_update_params
          response.should render_template('edit')
        end
      end
    end


    ########################################################################################
    #                                      DELETE DESTROY
    ########################################################################################
    describe "DELETE destroy" do
      before :each  do
        @invoice = Factory(:invoice)   
        @client = @invoice.client        
      end           
      it "should be authorized" do
        delete :destroy, :id => @invoice.id
        response.should_not redirect_to(default_unauthorized_path)        
      end
      it "should reduce invoice count by one" do
        lambda do
          delete :destroy, :id => @invoice.id
        end.should change(Invoice, :count).by(-1)
      end

      it "should make the invoices unfindable in the database" do    
        delete :destroy, :id => @invoice.id
        lambda{ Invoice.find(@invoice.id)}.should raise_error(ActiveRecord::RecordNotFound)      
      end

      it "should redirect to the invoices list" do
        delete :destroy, :id => @invoice.id
        response.should redirect_to(invoices_url)
      end
    end

  end

end
