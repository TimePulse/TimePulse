require 'spec_helper'

describe "/invoices/show" do
  include InvoicesHelper
  
  before(:each) do
    assign(:invoice, @invoice = Factory(:invoice))
  end

  it "should succeed" do
    render
    
  end
end

