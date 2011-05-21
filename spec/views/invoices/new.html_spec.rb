require 'spec_helper'

describe "/invoices/new" do
  include InvoicesHelper
  
  before(:each) do
    assigns[:invoice] = Factory.build(:invoice)
    @client = Factory(:client, :name => "Some Client", :abbreviation => "SCL")      
  end
  
  it "should succeed" do
    render "/invoices/new"
    response.should be_success
  end
  

  describe "without a client specified" do

    it "should not render create form" do
      render "/invoices/new"
      response.should_not have_tag("form[action=?][method=post]", invoices_path)
    end
    
    it "should have a new invoice form client selector" do
      render "/invoices/new"

      response.should have_tag("form[action=?][method=get]", new_invoice_path) do
        with_tag("select#client_id") do
          with_tag("option[value=#{@client.id}]")
        end
      end
    end
  end
  
  describe "with client specified" do
    before :each  do
      assigns[:client] = @client
      assigns[:invoice] = Invoice.new(:client => @client)
      assigns[:work_units] = [ Factory(:work_unit), Factory(:work_unit) ]
    end
    
    it "should pre-select that client in the selector" do
      render "/invoices/new"
      response.should have_tag("select#client_id") do
        with_tag("option[value=#{@client.id}][selected='selected']")
      end      
    end
    
    describe "create form" do
      before :each  do
        @work_units = assigns[:work_units] = [
          Factory(:work_unit),
          Factory(:work_unit)        
        ]        
      end
      it "should render" do
        render "/invoices/new"
        response.should have_tag("form[action=?][method=post]", invoices_path) do
          with_tag("textarea#invoice_notes[name=?]", "invoice[notes]")
          with_tag("input#invoice_reference_number[name=?]", "invoice[reference_number]")
        end
      end    
      it "should include a hidden tag for the client" do
        render "/invoices/new"
        response.should have_tag("form[action=?][method=post]", invoices_path) do
          with_tag("input#invoice_client_id[type=?][value=?]", "hidden", @client.id)
        end        
      end
      it "should include checkboxes for each work unit" do
        render "/invoices/new"
        @work_units.each do |wu|
          response.should have_tag("form[action=?][method=post]", invoices_path) do
            with_tag("input[type='checkbox'][name=?]", "invoice[work_unit_ids][#{wu.id}]")
          end                                                                            
        end
      end
      
    end
  end  
  
end


