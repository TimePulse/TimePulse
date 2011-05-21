require 'spec_helper'

describe "/bills/new" do
  include BillsHelper
  before :each do
    @user = Factory(:user)
  end
    
  describe "without a user specified" do
    it "should not render create form" do
      render "/bills/new"
      response.should_not have_tag("form[action=?][method=post]", bills_path)
    end

    it "should have a new bill form user selector" do
      render "/bills/new"

      response.should have_tag("form[action=?][method=get]", new_bill_path) do
        with_tag("select#user_id") do
          with_tag("option[value=#{@user.id}]")
        end
      end
    end
  end

  describe "with user specified" do
    before :each  do
      assigns[:user] = @user
      assigns[:bill] = Bill.new(:user => @user)
      assigns[:work_units] = [ Factory(:work_unit), Factory(:work_unit) ]
    end

    it "should pre-select that user in the selector" do
      render "/bills/new"
      response.should have_tag("select#user_id") do
        with_tag("option[value=#{@user.id}][selected='selected']")
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
        render "/bills/new"
        response.should have_tag("form[action=?][method=post]", bills_path) do
          with_tag("textarea#bill_notes[name=?]", "bill[notes]")
          with_tag("input#bill_reference_number[name=?]", "bill[reference_number]")
        end
      end    
      it "should include a hidden tag for the user" do
        render "/bills/new"
        response.should have_tag("form[action=?][method=post]", bills_path) do
          with_tag("input#bill_user_id[type=?][value=?]", "hidden", @user.id)
        end        
      end
      it "should include checkboxes for each work unit" do
        render "/bills/new"
        @work_units.each do |wu|
          response.should have_tag("form[action=?][method=post]", bills_path) do
            with_tag("input[type='checkbox'][name=?]", "bill[work_unit_ids][#{wu.id}]")
          end                                                                            
        end
      end

    end
  end  
  
end


