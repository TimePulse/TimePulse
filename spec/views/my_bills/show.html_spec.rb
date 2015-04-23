require 'spec_helper'

describe "/my_bills/show" do

  before(:each) do
    assign(:bill, @bill = FactoryGirl.create(:bill))
  end

  it "should succeed" do
    render

  end
end
