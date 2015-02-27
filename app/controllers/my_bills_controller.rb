require 'work_unit_tools'

class MyBillsController < ApplicationController
  before_filter :find_bill, :only => [ :show ]
  before_filter(:only => [ :show ]) { require_owner!(@bill.user) }

  include WorkUnitTools

  # GET /my_bills
  def index
    @unpaid_bills = UnpaidBillQuery.new(find_user_bills).find_for_page(params[:page])
    @paid_bills = PaidBillQuery.new(find_user_bills).find_for_page(params[:page])
  end

  # GET /my_bills/1
  def show
  end

  private

  def find_bill
    @bill = Bill.find(params[:bill_id])
    raise ArgumentError, 'Invalid bill id provided' unless @bill
  end

  def find_user_bills
    Bill.where(user_id: current_user.id)
  end
end
