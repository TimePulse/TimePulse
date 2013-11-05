require 'spec_helper'

describe "/invoices/show" do
  include InvoicesHelper

  let :project do FactoryGirl.create(:project) end

  before(:each) do
    assign(:invoice, @invoice = FactoryGirl.create(:invoice, :client => project.client))
  end

  it "should succeed" do
    render
  end

  it "should render invoice items" do
    render

    rendered.should have_selector('.invoice-items tbody tr')
  end
end

