require 'spec_helper'

describe "/bills/edit" do
  include BillsHelper
  
  before(:each) do
    assigns[:bill] = @bill = Factory(:bill)
  end
  
  it "should succeed" do
    render "/bills/edit"
    response.should be_success
  end

  it "should render edit form" do
    render "/bills/edit"
    
    response.should have_tag("form[action=#{bill_path(@bill)}][method=post]") do
      with_tag('textarea#bill_notes[name=?]', "bill[notes]")
    end
  end
end


