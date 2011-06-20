require 'spec_helper'

describe "/home/index" do
  before(:each) do
    @user = authenticate(:user)
    Factory(:work_unit, :user => @user)
    Factory(:work_unit, :user => @user)
  end

  it "should succeed" do
    render
  end

  describe "with a current, clockable project selected" do
    before :each do
      @user.current_project = Factory(:project, :name => "Foo Project", :clockable => true)
      @user.save!
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
  end

  describe "with an unclocable project current" do
    before :each do
      @user.current_project = Factory(:project, :name => "Foo Project", :clockable => false)
      @user.save!
    end
    it "should succeed" do
      render
    end
    it "should not have a work unit form" do
      render
      rendered.should_not have_selector("form#new_work_unit")
    end
  end
end