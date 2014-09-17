require 'work_unit_tools'

class InvoicesController < ApplicationController
  before_filter :find_invoice, :only => [ :show, :edit, :update, :destroy ]
  before_filter :require_admin!

  include WorkUnitTools

  # GET /invoices
  def index
    @unpaid_invoices = UnpaidInvoiceQuery.new.find_for_page(params[:page])
    @paid_invoices = PaidInvoiceQuery.new.find_for_page(params[:page])
  end

  # GET /invoices/1
  def show
  end

  # GET /invoices/new
  def new
    @invoice = Invoice.new(:due_on => Date.today + 21.days)
    @clients = Client.all.order('abbreviation asc')
    if params[:client_id]
      @client = find_user(Client, params[:client_id])
      @invoice.client = @client
      @work_units = WorkUnit.for_client(@client).order(stop_time: :asc).with_hours.billable.uninvoiced.flatten.uniq
    end
  end

  # GET /invoices/1/edit
  def edit
  end

  # POST /invoices
  def create
    @invoice = Invoice.new(invoice_params)
    add_work_units(@invoice, params[:invoice][:work_unit_ids])
    if @invoice.save
      flash[:notice] = 'Invoice was successfully created.'
      redirect_to(@invoice)
    else
      flash[:error] = "Could not save invoice.  errors: #{error_list}"
      params[:client_id] = @invoice.client.id if @invoice.client
      render :action => "new"
    end
  end

  # PUT /invoices/1
  def update
    if @invoice.update_attributes(invoice_params)
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

  # def find_client
  #   @client = Client.find_by_id(params[:client_id])
  #   unless @client
  #     flash[:error] = "Could not find the specified client"
  #     redirect_to :back
  #   end
  # end

  def error_list
    @invoice.errors.map{ |error, message| message }.join(', ')
  end

  # def add_work_units
  #   if params[:invoice][:work_unit_ids]
  #     @invoice.work_units = []
  #     params[:invoice][:work_unit_ids].each do |id, bool|
  #       @invoice.work_units << WorkUnit.find(id) if bool == "1"
  #     end
  #   end
  # end

  def invoice_params
    params.require(:invoice)
    .permit(:notes,
      :due_on,
      :paid_on,
      :reference_number,
      :client_id)
  end

end
