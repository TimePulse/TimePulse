require 'spec_helper'

describe "/invoice_reports/show" do
  include InvoicesHelper

  let :project do FactoryGirl.create(:project) end

  before(:each) do
    assign(:invoice, @invoice = FactoryGirl.create(:invoice, :client => project.client))
    assign(:invoice_report, InvoiceReport.new(@invoice))
  end

  it "should succeed" do
    render
  end
end

