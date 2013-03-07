class BillsController < ApplicationController
  before_filter :find_bill, :only => [ :show, :edit, :update, :destroy ]
  before_filter :authenticate_admin

  # GET /bills
  def index
    @unpaid_bills = Bill.unpaid.paginate(:per_page => 10, :page => params[:page], :order => "due_on DESC, created_at DESC")
    @paid_bills = Bill.paid.paginate(:per_page => 10, :page => params[:page], :order => "paid_on DESC, created_at DESC")
  end

  # GET /bills/1
  def show
  end

  # GET /bills/new
  def new
    @bill = Bill.new(:due_on => Date.today + 21.days)
    @users = User.find(:all, :order => 'name ASC')
    if params[:user_id]
      find_user
      @bill.user = @user
      @work_units = @user.work_units.completed.billable.unbilled.flatten.uniq
    end
  end

  # GET /bills/1/edit
  def edit
  end

  # POST /invoices
  def create
    @bill = Bill.new(params[:bill])
    add_work_units
    if @bill.save
      flash[:notice] = 'Bill was successfully created.'
      redirect_to(@bill)
    else
      params[:user_id] = @bill.user.id if @bill.user
      render :action => "new"
    end
  end

  # PUT /bills/1
  def update
    if @bill.update_attributes(params[:bill])
      flash[:notice] = 'Bill was successfully updated.'
      redirect_to(@bill)
    else
      render :action => "edit"
    end
  end

  # DELETE /bills/1
  def destroy
    @bill.destroy
    redirect_to(bills_url)
  end

  private

  def find_bill
    @bill = Bill.find(params[:id])
    raise ArgumentError, 'Invalid bill id provided' unless @bill
  end

  def find_user
    @user = User.find_by_id(params[:user_id])
    unless @user
      flash[:error] = "Could not find the specified user"
      redirect_to :back
    end
  end

  def add_work_units
    if params[:bill][:work_unit_ids]
      @bill.work_units = []
      params[:bill][:work_unit_ids].each do |id, bool|
        @bill.work_units << WorkUnit.find(id) if bool == "1"
      end
    end
  end
end
