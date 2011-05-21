require 'spec_helper'

describe "/bills/show" do
  include BillsHelper
  
  before(:each) do
    assigns[:bill] = @bill = Factory(:bill)
  end

  it "should succeed" do
    render "/bills/show"
    response.should be_success
  end
end

