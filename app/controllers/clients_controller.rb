class ClientsController < ApplicationController
  before_filter :require_admin!

  # GET /clients
  def index
    @clients = Client.all
  end

  # GET /clients/1
  def show
    @client = Client.find(params[:id])
  end

  # GET /clients/new
  def new
    @client = Client.new
  end

  # GET /clients/1/edit
  def edit
    @client = Client.find(params[:id])
  end

  # POST /clients
  def create
    @client = Client.new(client_params)

    if @client.save
      flash[:notice] = 'Client was successfully created.'
      redirect_to(@client)
    else
      render :action => "new"
    end
  end

  # PUT /clients/1
  # PUT /clients/1.xml
  def update
    @client = Client.find(params[:id])

    if @client.update(client_params)
      flash[:notice] = 'Client was successfully updated.'
      redirect_to(@client)
    else
      render :action => "edit"
    end
  end

  # DELETE /clients/1
  def destroy
    @client = Client.find(params[:id])
    @client.destroy

    redirect_to(clients_url)
  end

  private

  def client_params
    params.
    require(:client).
    permit(:name,
      :billing_email,
      :address_1,
      :address_2,
      :city,
      :state,
      :postal,
      :abbreviation)
  end

end
