require 'spec_helper'

describe "/bills/edit" do
  include BillsHelper

  before(:each) do
    assign(:bill, @bill = FactoryGirl.create(:bill))
  end

  it "should succeed" do
    render

  end

  it "should render edit form" do
    render

    rendered.should have_selector("form[action='#{bill_path(@bill)}'][method='post']") do |scope|
      scope.should have_selector("textarea#bill_notes[name='bill[notes]']")
    end
  end
end


