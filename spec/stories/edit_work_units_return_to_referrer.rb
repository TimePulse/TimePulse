require 'spec_helper'

steps "Admin edits a work unit", :type => :feature do
  let! :client do FactoryGirl.create(:client, :name => 'Foo, Inc.') end
  let! :project do FactoryGirl.create(:project, :client => client) end
  let! :user      do FactoryGirl.create(:user, :current_project => project) end

  let! :wu     do FactoryGirl.create(:work_unit, {:project => project, :user => user} ) end

  let! :admin do FactoryGirl.create(:admin) end

  it "should login as the admin" do
    visit root_path
    fill_in "Login", :with => admin.login
    fill_in "Password", :with => admin.password
    click_button 'Login'
  end

  it "should be on projects page" do
    click_link 'Projects'
  end

  it "should be on projects page" do
    within ("#content") do
      page.should have_content("Listing Projects")
    end
  end

  it "should have a project edit button" do
    within ".listing" do
      page.should have_selector("a.actions.edit")
      click_link 'Edit'
    end
  end

  it "Edit a work unit" do
    page.should have_content("Editing Project")
  end

  it "should have a submit button" do
    page.should have_button("Submit")
    click_button('Submit')
  end

  it "should go to the back to the calling page" do
    within ("#content") do
      page.should have_content("Listing Projects")
    end
  end

end
