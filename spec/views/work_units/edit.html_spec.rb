require 'spec_helper'

describe "/work_units/edit" do
  include WorkUnitsHelper
  
  before(:each) do
    assigns[:work_unit] = @work_unit = Factory(:work_unit)
  end
  
  it "should succeed" do
    render "/work_units/edit"
    response.should be_success
  end

  it "should render edit form" do
    render "/work_units/edit"
    
    response.should have_tag("form[action=#{work_unit_path(@work_unit)}][method=post]") do
      with_tag('input#work_unit_hours[name=?]', "work_unit[hours]")
      with_tag('input#work_unit_notes[name=?]', "work_unit[notes]")
    end
  end
end


