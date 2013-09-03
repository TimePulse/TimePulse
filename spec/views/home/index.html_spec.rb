require 'spec_helper'

describe "/home/index" do
  before(:each) do
    @current_user = authenticate(:user)
    Factory(:work_unit, :user => @current_user)
    Factory(:work_unit, :user => @current_user)
  end

  it "should succeed" do
    render
  end

  describe "with a current, clockable project selected" do
    before do
      @current_user.current_project = Factory(:project, :name => "Foo Project", :clockable => true)
      @current_user.save!
      assign(:user, @current_user)
      assign(:current_project, @current_user.current_project)
      assign(:work_units, [ Factory(:work_unit), Factory(:work_unit) ].paginate )
    end
    it "should succeed" do
      render
    end
    it "should have a work unit form" do
      render
      rendered.should have_selector("form#new_work_unit[action='/work_units']")
    end
    it "should have a 'Save Changes' submit button" do
      render
      rendered.should have_selector("input[name='commit'][value='Save Changes']")
    end
    it "should have a list of work units" do
      render
      rendered.should have_selector("tr.work_unit.one_line")
    end
  end

  describe "with an unclockable project current" do
    before :each do
      @current_user.current_project = Factory(:project, :name => "Foo Project", :clockable => false)
      @current_user.save!
    end
    it "should succeed" do
      render
    end
    it "should not have a work unit form" do
      render
      rendered.should_not have_selector("form#new_work_unit")
    end
  end

  describe "with billable and unbillable work units" do
    before :each do
      @billable_wu = Factory(:work_unit, :user => @current_user, :billable => true)
      @unbillable_wu = Factory(:work_unit, :user => @current_user, :billable => false)
      @current_user.current_project = Factory(:project, :name => "Foo Project", :clockable => true)
      @current_user.save!
      assign(:user, @current_user)
      assign(:current_project, @current_user.current_project)
      assign(:work_units, [ @billable_wu, @unbillable_wu ].paginate )
    end

    it "should have a check mark for the billable work unit" do
      render
      rendered.should have_selector "#work_unit_#{@billable_wu.id}"
    end

    it "should not have a check mark for the billable work unit" do
      render
      rendered.should_not have_selector "#work_unit_#{@unbillable_wu.id}"
    end
  end
end
