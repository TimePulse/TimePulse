require 'spec_helper'

describe "/bills/index" do
  include BillsHelper
  
  before(:each) do
    assigns[:unpaid_bills] = [ Factory(:bill), Factory(:bill) ].paginate
    assigns[:paid_bills] = [ Factory(:bill), Factory(:bill) ].paginate
  end

  it "should succeed" do
    render "/bills/index"
    response.should be_success
  end
end

