require 'spec_helper'

steps "Minute truncation", :type => :feature do
  let! :client do FactoryGirl.create(:client, :name => 'Foo, Inc.') end
  let! :project do FactoryGirl.create(:project, :client => client) end
  let! :unclockable_project do
    FactoryGirl.create(:project, client: client, clockable: false,
                       name: "Don't Clock Me")
  end
  let! :user do FactoryGirl.create(:user, :current_project => project) end
  let! :wu do
    FactoryGirl.create(:work_unit, {:start_time => Time.new(2013,8,1,14,54,00),
                                    :stop_time  => Time.new(2013,8,1,18,18,45),
                                    :hours      => 3.41, :project => project,
                                    :user => user} )
  end
  let! :annotation do FactoryGirl.create(:activity, :work_unit => wu, :project => project, :description => "This is an annotation.") end

  it "should login as User" do
    visit root_path
    fill_in "Login", :with => user.login
    fill_in "Password", :with => user.password
    click_button 'Login'
    page.should have_link("Logout")
  end

  it "should visit the edit work unit page" do
    within "#aux #recent_work" do
      page.should have_selector("a.actions.edit")
      click_link 'Edit'
    end
  end

  it "should display the options to Edit" do
    page.should have_content("Billable")
    page.should have_checked_field( 'work_unit_billable' )
  end

  it "should list annotations associated with this work unit" do
    page.should have_content("ANNOTATIONS")
    page.should have_content("This is an annotation.")
  end

  it "should allow addition of annotations and list them" do
    fill_in "wu_annotation_input", :with => "This is another annotation!\n"
    page.should have_content("This is another annotation!")
  end

  it "should allow deletion of annotations" do
    expect do
      click_link("Delete", match: :first)
      page.should_not have_content("This is another annotation!")
    end.to change(Activity, :count).by(-1)
  end

  it "should not allow unclockable projects to be selected" do
    # Check the underlying HTML used to build the project picker
    page.should have_xpath("//option[@disabled='disabled'][@value='#{unclockable_project.id}']", visible: false)

    # Open the project picker, and look for the disabled option
    page.find(:css, "#work_unit_project_idSelectBoxIt").click
    page.should have_xpath("//li[@data-disabled='true'][@data-val='#{unclockable_project.id}']")
  end

  it "should not cause errors in the edit view" do
    click_button("Submit")
    page.should_not have_content("Hours must not be greater than the difference between start and stop times")
    page.should have_content("TIMECLOCK")
  end
end
