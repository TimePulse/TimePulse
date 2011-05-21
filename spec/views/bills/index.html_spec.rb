require 'spec_helper'

describe "/bills/index" do
  include BillsHelper
  
  before(:each) do
    assign(:unpaid_bills, [ Factory(:bill), Factory(:bill) ].paginate)
    assign(:paid_bills, [ Factory(:bill), Factory(:bill) ].paginate)
  end

  it "should succeed" do
    render
    
  end
end

