require 'spec_helper'

describe "/work_units/show" do
  include WorkUnitsHelper

  before(:each) do
    assign(:work_unit, @work_unit = FactoryGirl.create(:work_unit))
  end

  it "should succeed" do
    render

  end
end

