require 'spec_helper'

describe "/work_units/show" do
  include WorkUnitsHelper
  
  before(:each) do
    assigns[:work_unit] = @work_unit = Factory(:work_unit)
  end

  it "should succeed" do
    render "/work_units/show"
    response.should be_success
  end
end

