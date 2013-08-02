require 'spec_helper'

describe "/invoices/index" do
  include InvoicesHelper

  let :project do Factory(:project) end

  before(:each) do
    assign(:unpaid_invoices, [ Factory(:invoice, :client => project.client), Factory(:invoice, :client => project.client) ].paginate)
    assign(:paid_invoices, [ Factory(:invoice, :client => project.client), Factory(:invoice, :client => project.client) ].paginate)
  end

  it "should succeed" do
    render
  end
end

