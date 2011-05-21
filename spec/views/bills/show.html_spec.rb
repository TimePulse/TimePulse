require 'spec_helper'

describe "/bills/show" do
  include BillsHelper
  
  before(:each) do
    assign(:bill, @bill = Factory(:bill))
  end

  it "should succeed" do
    render
    
  end
end

