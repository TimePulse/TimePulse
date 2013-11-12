require 'spec_helper'

describe UnpaidInvoiceQuery, :type => :query do
  let :project do FactoryGirl.create(:project) end

  before(:each) do
    @invoice = FactoryGirl.create(:invoice, :client => project.client, :due_on => nil, :due_on => Date.today + 1.week)
    @unpaid_invoices = [
        @invoice,
        FactoryGirl.create(:invoice, :client => project.client, :paid_on => nil, :due_on => Date.today + 1.month),
        FactoryGirl.create(:invoice, :client => project.client, :paid_on => nil, :due_on => Date.today + 3.weeks)
    ].sort_by{|b| b.due_on}.reverse
    @paid_invoices = [
      FactoryGirl.create(:invoice, :client => project.client, :paid_on => Date.today - 1.day),
      FactoryGirl.create(:invoice, :client => project.client, :paid_on => Date.today - 2.day)
    ].sort_by{|b| b.paid_on}.reverse
  end

  subject do
    PaidInvoiceQuery.new
  end

  it "should find the unpaid bills" do
    subject.find_for_page(nil).should == @paid_invoices.paginate
  end
end