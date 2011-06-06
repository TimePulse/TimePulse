require 'spec_helper'

describe ClientsController do
  before(:each) do
    authenticate(:admin)
  end

  let! :client do
    @client ||= Factory(:client)
  end

  describe "GET index" do
    it "assigns all clients as @clients" do
      get :index
      assigns[:clients].should == [client]
    end
  end

  describe "GET show" do
    it "assigns the requested client as @client" do
      get :show, :id => client.id
      assigns[:client].should == client
    end
  end

  describe "GET new" do
    it "assigns a new client as @client" do
      get :new
      assigns[:client].should be_a(Client)
      assigns[:client].should be_new_record
    end
  end

  describe "GET edit" do
    it "assigns the requested client as @client" do
      get :edit, :id => client.id
      assigns[:client].should == client
    end
  end

  describe "POST create" do
    def valid_params
      { :name => 'Foobar Industries',
        :billing_email => "billing@foobar.com"
      }
    end

    describe "with valid params" do
      it "assigns a newly created client as @client" do
        post :create, :client => valid_params
        assigns[:client].should be_a(Client)
        assigns[:client].name.should == 'Foobar Industries'
      end

      it "redirects to the created client" do
        post :create, :client => valid_params
        response.should redirect_to(client_url(assigns[:client]))
      end

      it "creates a new Client in the database" do
        lambda do
          post :create, :client => valid_params
        end.should change(Client, :count).by(1)
      end
    end

    describe "with invalid params" do
      def invalid_params
        { :name => nil,
          :billing_email => "billing@foobar.com"
        }
      end

      it "assigns a newly created but unsaved client as @client" do
        post :create, :client => invalid_params
        assigns[:client].should be_a(Client)
        assigns[:client].name.should be_nil
        assigns[:client].should be_new_record
      end

      it "re-renders the 'new' template" do
        post :create, :client => invalid_params
        response.should render_template('new')
      end
    end

  end

  describe "PUT update" do
    def valid_params
      { :name => 'Foobar Industries'
      }
    end

    describe "with valid params" do
      it "updates the requested client" do
        put :update, :id => client.id, :client => valid_params
      end

      it "assigns the requested client as @client" do
        put :update, :id => client.id, :client => valid_params
        assigns[:client].should == client
      end

      it "changes the value" do
        lambda do
          put :update, :id => client.id, :client => valid_params
        end.should change{client.reload.name}
      end

      it "redirects to the client" do
        put :update, :id => client.id, :client => valid_params
        response.should redirect_to(client_url(client))
      end
    end

    describe "with invalid params" do
      def invalid_params
        { :name => nil }
      end
      it "updates the requested client" do
        put :update, :id => client.id, :client => invalid_params
      end

      it "assigns the client as @client" do
        put :update, :id => client.id, :client => invalid_params
        assigns[:client].should == client
      end

      it "re-renders the 'edit' template" do
        put :update, :id => client.id, :client => invalid_params
        response.should render_template('edit')
      end
    end

  end

  describe "DELETE destroy" do
     it "should reduce client count by one" do
        lambda do
          delete :destroy, :id => client.id
        end.should change(Client, :count).by(-1)
      end

      it "should make the clients unfindable in the database" do
        delete :destroy, :id => client.id
        lambda{ Client.find(client.id)}.should raise_error(ActiveRecord::RecordNotFound)
      end

      it "should redirect to the clients list" do
        delete :destroy, :id => client.id
        response.should redirect_to(clients_path)
      end
  end

end
