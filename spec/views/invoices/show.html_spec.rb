require 'spec_helper'

describe "/invoices/show" do
  include InvoicesHelper
  
  before(:each) do
    assigns[:invoice] = @invoice = Factory(:invoice)
  end

  it "should succeed" do
    render "/invoices/show"
    response.should be_success
  end
end

