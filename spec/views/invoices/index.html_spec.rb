require 'spec_helper'

describe "/invoices/index" do
  include InvoicesHelper
  
  before(:each) do
    assigns[:unpaid_invoices] = [ Factory(:invoice), Factory(:invoice) ].paginate
    assigns[:paid_invoices] = [ Factory(:invoice), Factory(:invoice) ].paginate
  end

  it "should succeed" do
    render "/invoices/index"
    response.should be_success
  end
end

