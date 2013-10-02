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

describe "/home/index" do

  describe "recent projects box" do
    let! :current_user do authenticate(:user) end
    let! :other_user do Factory(:user) end
    let! :project_1 do Factory(:project) end
    let! :project_2 do Factory(:project) end
    let! :project_3 do Factory(:project) end
    let! :project_4 do Factory(:project) end
    let! :project_5 do Factory(:project) end
    let! :project_6 do Factory(:project) end
    let! :project_7 do Factory(:project) end
    #This set of work units tests the following cases:
    #  Base Ordering
    #  Ignoring work units performed by another user, whether or not current_user performed work on that project 
    #  Correctly ordering projects that were already on the list when another work unit was performed
    #  Maintaining uniqueness of projects on the list, even when multiple work units are performed on a single project.
    let! :wu_1 do Factory(:work_unit,  {:user => current_user, :project => project_1, :start_time => Time.now - 10.days}) end
    let! :wu_2 do Factory(:work_unit,  {:user => current_user, :project => project_2, :start_time => Time.now -  9.days}) end
    let! :wu_3 do Factory(:work_unit,  {:user => current_user, :project => project_3, :start_time => Time.now -  8.days}) end
    let! :wu_4 do Factory(:work_unit,  {:user => other_user,   :project => project_4, :start_time => Time.now -  7.days}) end
    let! :wu_5 do Factory(:work_unit,  {:user => current_user, :project => project_5, :start_time => Time.now -  6.days}) end
    let! :wu_6 do Factory(:work_unit,  {:user => current_user, :project => project_6, :start_time => Time.now -  5.days}) end
    let! :wu_7 do Factory(:work_unit,  {:user => current_user, :project => project_7, :start_time => Time.now -  4.days}) end 
    let! :wu_8 do Factory(:work_unit,  {:user => other_user,   :project => project_6, :start_time => Time.now -  3.days}) end 
    let! :wu_9 do Factory(:work_unit,  {:user => current_user, :project => project_5, :start_time => Time.now -  2.days}) end 
    let! :wu_10 do Factory(:work_unit, {:user => current_user, :project => project_5, :start_time => Time.now -  1.days}) end 
    
    it "should render a recent projects block with the five most recent projects from the current user in the correct order" do
      render
      @picker = view.content_for(:picker)
      @picker.index(short_name_with_client(project_5)).should < @picker.index(short_name_with_client(project_7))
      @picker.index(short_name_with_client(project_7)).should < @picker.index(short_name_with_client(project_6))
      @picker.index(short_name_with_client(project_6)).should < @picker.index(short_name_with_client(project_3))
      @picker.index(short_name_with_client(project_3)).should < @picker.index(short_name_with_client(project_2))
    end

    it "should not render older projects or projects for other users" do
      render
      @picker = view.content_for(:picker)
      @picker.should_not have_text(short_name_with_client(project_1))
      @picker.should_not have_text(short_name_with_client(project_4))
    end
  end
end

