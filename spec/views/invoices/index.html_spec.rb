require 'spec_helper'

describe "/invoices/index" do
  include InvoicesHelper

  let :project do FactoryGirl.create(:project) end

  before(:each) do
    assign(:unpaid_invoices, [ FactoryGirl.create(:invoice, :client => project.client), FactoryGirl.create(:invoice, :client => project.client) ].paginate)
    assign(:paid_invoices, [ FactoryGirl.create(:invoice, :client => project.client), FactoryGirl.create(:invoice, :client => project.client) ].paginate)
  end

  it "should succeed" do
    render
  end
end

