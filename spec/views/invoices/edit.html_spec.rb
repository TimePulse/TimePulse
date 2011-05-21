require 'spec_helper'

describe "/invoices/edit" do
  include InvoicesHelper
  
  before(:each) do
    assigns[:invoice] = @invoice = Factory(:invoice)
  end
  
  it "should succeed" do
    render "/invoices/edit"
    response.should be_success
  end

  it "should render edit form" do
    render "/invoices/edit"
    
    response.should have_tag("form[action=#{invoice_path(@invoice)}][method=post]") do
      with_tag('textarea#invoice_notes[name=?]', "invoice[notes]")
      with_tag('input#invoice_reference_number[name=?]', "invoice[reference_number]")
    end
  end
end


