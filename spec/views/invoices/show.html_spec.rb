require 'spec_helper'

describe "/invoices/show" do
  include InvoicesHelper

  let :project do Factory(:project) end

  before(:each) do
    assign(:invoice, @invoice = Factory(:invoice, :client => project.client))
  end

  it "should succeed" do
    render
  end
end

