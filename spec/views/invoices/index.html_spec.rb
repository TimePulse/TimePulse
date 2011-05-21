require 'spec_helper'

describe "/invoices/index" do
  include InvoicesHelper
  
  before(:each) do
    assign(:unpaid_invoices, [ Factory(:invoice), Factory(:invoice) ].paginate)
    assign(:paid_invoices, [ Factory(:invoice), Factory(:invoice) ].paginate)
  end

  it "should succeed" do
    render
    
  end
end

