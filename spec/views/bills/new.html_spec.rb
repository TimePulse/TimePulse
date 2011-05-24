require 'spec_helper'

describe "/bills/new" do
  include BillsHelper
  before :each do
    @user = Factory(:user)
  end

  describe "without a user specified" do
    it "should not render create form" do
      render
      rendered.should_not have_selector("form[action='#{bills_path}'][method='post']")
    end

    it "should have a new bill form user selector" do
      render

      rendered.should have_selector("form[action='#{new_bill_path}'][method='get']") do |scope|
        scope.should have_selector("select#user_id") do
          scope.should have_selector("option[value=#{@user.id}]")
        end
      end
    end
  end

  describe "with user specified" do
    before :each  do
      assign(:user, @user)
      assign(:bill, Bill.new(:user => @user))
      assign(:work_units, [ Factory(:work_unit), Factory(:work_unit) ])
    end

    it "should pre-select that user in the selector" do
      render
      rendered.should have_selector("select#user_id") do |scope|
        scope.should have_selector("option[value=#{@user.id}][selected='selected']")
      end
    end

    describe "create form" do
      before :each  do
        @work_units = assign(:work_units, [
          Factory(:work_unit),
          Factory(:work_unit)
        ])
      end
      it "should render" do
        render
        rendered.should have_selector("form[action='#{bills_path}'][method='post']") do |scope|
          scope.should have_selector("textarea#bill_notes[name='bill[notes]']")
          scope.should have_selector("input#bill_reference_number[name='bill[reference_number]']")
        end
      end
      it "should include a hidden tag for the user" do
        render
        rendered.should have_selector("form[action='#{bills_path}'][method='post']") do |scope|
          scope.should have_selector("input#bill_user_id[type=?][value='hidden']")
        end
      end
      it "should include checkboxes for each work unit" do
        render
        @work_units.each do |wu|
          rendered.should have_selector("form[action='#{bills_path}'][method='post']") do |scope|
            scope.should have_selector("input[type='checkbox'][name='bill[work_unit_ids][#{wu.id}]']")
          end
        end
      end

    end
  end

end


