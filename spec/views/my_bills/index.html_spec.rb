require 'spec_helper'

describe "/my_bills/index" do

  before(:each) do
    assign(:unpaid_bills, [ FactoryGirl.create(:bill), FactoryGirl.create(:bill) ].paginate)
    assign(:paid_bills, [ FactoryGirl.create(:bill), FactoryGirl.create(:bill) ].paginate)
  end

  it "should succeed" do
    render
  end
end
