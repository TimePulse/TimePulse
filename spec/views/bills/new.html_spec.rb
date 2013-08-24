require 'spec_helper'

describe "/bills/new" do
  include BillsHelper

  let! :user do
    Factory(:user)
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
          scope.should have_selector("option[value='#{user.id}']")
        end
      end
    end

    describe "when inactive users are present" do

      let! :inactive_user do 
        Factory(:user, :inactive => true) 
      end
      
      it "should only show active users" do
        render
        rendered.should have_selector("option[value='#{user.id}']")
        rendered.should_not have_selector("option[value='#{inactive_user.id}']")
      end
    end
  end

  describe "with user specified" do
    before :each  do
      assign(:bill, Bill.new(:user => user))
      assign(:work_units, @work_units = [
        Factory(:work_unit, :user => user),
        Factory(:work_unit, :user => user) ]
      )
      assign(:user, user)
    end

    it "should pre-select that user in the selector" do
      render
      rendered.should have_selector("select#user_id") do |scope|
        scope.should have_selector("option[value='#{user.id}'][selected='selected']")
      end
    end

    describe "create form" do
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
          scope.should have_selector("input#bill_user_id[type='hidden'][value='#{user.id}']")
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


