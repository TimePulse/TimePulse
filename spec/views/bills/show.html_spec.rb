require 'spec_helper'

describe "/bills/show" do
  include BillsHelper

  before(:each) do
    @bill = FactoryGirl.create(:bill)
    assign(:bill, @bill)
    assign(:report, BillReport.new(@bill))
  end

  it "should succeed" do
    render
  end
end
