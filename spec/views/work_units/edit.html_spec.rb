require 'spec_helper'

describe "/work_units/edit" do
  include WorkUnitsHelper

  before(:each) do
    assign(:work_unit, @work_unit = FactoryGirl.create(:work_unit))
  end

  it "should succeed" do
    render
  end

  it "should render edit form" do
    render
    rendered.should have_selector("form[action='#{work_unit_path(@work_unit)}'][method='post']") do |scope|
      scope.should have_selector("input#work_unit_hours[name='work_unit[hours]']")
      scope.should have_selector("input#work_unit_notes[name='work_unit[notes]']")
    end
  end
end


