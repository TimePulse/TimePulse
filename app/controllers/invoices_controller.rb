class InvoicesController < ApplicationController
  before_filter :find_invoice, :only => [ :show, :edit, :update, :destroy ]
  before_filter :authenticate_admin

  # GET /invoices
  def index
    @unpaid_invoices = Invoice.unpaid.paginate(:per_page => 10, :page => params[:page], :order => "due_on DESC, created_at DESC")
    @paid_invoices = Invoice.paid.paginate(:per_page => 10, :page => params[:page], :order => "paid_on DESC, created_at DESC")    
  end

  # GET /invoices/1
  def show
  end

  # GET /invoices/new
  def new
    @invoice = Invoice.new(:due_on => Date.today + 21.days)
    @clients = Client.find(:all, :order => 'abbreviation ASC')
    if params[:client_id]
      find_client
      @invoice.client = @client      
      @work_units = WorkUnit.for_client(@client).completed.billable.uninvoiced.flatten.uniq
    end
  end

  # GET /invoices/1/edit
  def edit
  end

  # POST /invoices
  def create
    @invoice = Invoice.new(params[:invoice])
    add_work_units
    if @invoice.save
      flash[:notice] = 'Invoice was successfully created.'
      redirect_to(@invoice)
    else
      str = "Could not save invoice.  errors: #{@invoice.errors}"
      Rails.logger.info(str)
      flash[:error] = str
      params[:client_id] = @invoice.client.id if @invoice.client 
      render :action => "new"
    end
  end

  # PUT /invoices/1
  def update
    if @invoice.update_attributes(params[:invoice])
      flash[:notice] = 'Invoice was successfully updated.'
      redirect_to(@invoice)
    else
      render :action => "edit"
    end
  end

  # DELETE /invoices/1
  def destroy
    @invoice.destroy
    redirect_to(invoices_url)
  end

  private

  def find_invoice
    @invoice = Invoice.find(params[:id])
    raise ArgumentError, 'Invalid invoice id provided' unless @invoice
  end
  
  def find_client
    @client = Client.find_by_id(params[:client_id])
    unless @client
      flash[:error] = "Could not find the specified client"
      redirect_to :back
    end
  end
  
  def add_work_units
    if params[:invoice][:work_unit_ids]
      Rails.logger.info("&&&&&&&&&&&&& Adding work units")
      @invoice.work_units = []
      params[:invoice][:work_unit_ids].each do |id, bool|
        Rails.logger.info("&&&&&&&&&&&&& #{id} #{bool}")
        @invoice.work_units << WorkUnit.find(id) if bool == "1"
      end
    end
  end
end
