require 'spec_helper'

describe "/work_units/index" do
  include WorkUnitsHelper
  
  before(:each) do
    assign(:work_units, [ Factory(:work_unit), Factory(:work_unit) ])
  end

  it "should succeed" do
    render
    
  end
end

