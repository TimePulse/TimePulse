require 'spec_helper'

describe "/invoice_reports/show" do
  include InvoicesHelper
  
  before(:each) do
    assign(:invoice, @invoice = Factory(:invoice))
    assign(:invoice_report, InvoiceReport.new(@invoice))
  end

  it "should succeed" do
    render
    
  end
end

