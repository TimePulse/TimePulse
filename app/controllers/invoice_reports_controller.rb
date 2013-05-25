class InvoiceReportsController < ApplicationController
  before_filter :authenticate_admin!
  def show
     @invoice = Invoice.find(params[:id])
     @invoice_report = InvoiceReport.new(@invoice)
  end
end