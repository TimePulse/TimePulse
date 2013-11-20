require 'spec_helper'

describe "/invoices/new" do
  include InvoicesHelper

  before(:each) do
    assign(:invoice, FactoryGirl.build(:invoice))
    @client_local = FactoryGirl.create(:client, :name => "Some Client", :abbreviation => "SCL")
    assign(:work_units, [])
  end

  it "should succeed" do
    render
  end


  describe "without a client specified" do

    it "should not render create form" do
      render
      rendered.should_not have_selector("form[action='#{invoices_path}'][method='post']")
    end

    it "should have a new invoice form client selector" do
      render

      rendered.should have_selector("form[action='#{new_invoice_path}'][method='get']") do |scope|
        scope.should have_selector("select#client_id") do
          scope.should have_selector("option[value='#{@client_local.id}']")
        end
      end
    end
  end

  describe "with client specified" do
    let :invoice do
      inv = Invoice.new
      inv.client = @client_local
      inv
    end

    before :each  do
      assign(:client, @client_local)
      assign(:invoice, invoice)
      assign(:work_units, [ FactoryGirl.create(:work_unit), FactoryGirl.create(:work_unit) ])
    end

    it "should pre-select that client in the selector" do
      render
      rendered.should have_selector("select#client_id") do |scope|
        scope.should have_selector("option[value='#{@client_local.id}'][selected='selected']")
      end
    end

    describe "create form" do
      before :each  do
        @work_units = assign(:work_units, [
          FactoryGirl.create(:work_unit),
          FactoryGirl.create(:work_unit)
        ])
      end
      it "should render" do
        render
        rendered.should have_selector("form[action='#{invoices_path}'][method='post']") do |scope|
          scope.should have_selector("textarea#invoice_notes[name='invoice[notes]']")
          scope.should have_selector("input#invoice_reference_number[name='invoice[reference_number]']")
        end
      end
      it "should include a hidden tag for the client" do
        render
        rendered.should have_selector("form[action='#{invoices_path}'][method='post']") do |scope|
          scope.should have_selector("input#invoice_client_id[type='hidden'][value='#{@client_local.id}']")
        end
      end
      it "should include checkboxes for each work unit" do
        render
        @work_units.each do |wu|
          rendered.should have_selector("form[action='#{invoices_path}'][method='post']") do |scope|
            scope.should have_selector("input[type='checkbox'][name='invoice[work_unit_ids][#{wu.id}]']")
          end
        end
      end

    end
  end

end


