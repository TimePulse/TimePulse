require 'spec_helper'

describe "/work_units/new" do
  include WorkUnitsHelper
  
  before(:each) do
    assigns[:work_unit] = Factory.build(:work_unit)
  end
  
  it "should succeed" do
    render "/work_units/new"
    response.should be_success
  end
  

  it "should render new form" do
    render "/work_units/new"
    
    response.should have_tag("form[action=?][method=post]", work_units_path) do
      with_tag("input#work_unit_hours[name=?]", "work_unit[hours]")
      with_tag("input#work_unit_notes[name=?]", "work_unit[notes]")
    end
  end
end


