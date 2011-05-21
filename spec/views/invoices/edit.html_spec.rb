require 'spec_helper'

describe "/invoices/edit" do
  include InvoicesHelper
  
  before(:each) do
    assign(:invoice, @invoice = Factory(:invoice))
  end
  
  it "should succeed" do
    render
    
  end

  it "should render edit form" do
    render
    
    rendered.should have_selector("form[action=#{invoice_path(@invoice)}][method='post']") do |scope|
      scope.should have_selector("textarea#invoice_notes[name='invoice[notes]']")
      scope.should have_selector("input#invoice_reference_number[name='invoice[reference_number]']")
    end
  end
end


