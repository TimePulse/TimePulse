require 'spec_helper'

steps "Admin archives a project", :type => :feature do
  let! :client_1 do FactoryGirl.create(:client, :name => 'Foo, Inc.', :abbreviation => 'FOO') end
  let! :client_2 do FactoryGirl.create(:client, :name => 'Bar, Inc.', :abbreviation => 'BAR') end
  let! :project_active do FactoryGirl.create(:project, :client => client_1, :name => "Active Project") end

  let! :project_archive do FactoryGirl.create(:project, :client => client_2, :name => 'Inactive Project', :archived => true) end

  let! :admin do FactoryGirl.create(:admin) end

  it "should login as the admin" do
    visit root_path
    fill_in "Login", :with => admin.login
    fill_in "Password", :with => admin.password
    click_button 'Login'
  end

  it "should be on projects page" do
    click_link 'Projects'
    page.should have_content("Listing Projects")
  end


  it "and have an active tab" do
    within ".tab_selected" do
      page.should have_content("Active")
    end
  end

  it "and we should see the active project" do
    page.should have_content "Active Project"
  end

  it "and we should not see the archived project" do
    page.should_not have_content "Inactive Project"
  end


  it "and we go to the archive tab" do
    click_link "Archived"
  end

  it "and we not should see the active project" do
    page.should_not have_content "Active Project"
  end

  it "and we should see the archived project" do
    page.should have_content "Inactive Project"
  end


  it "and we go to the active tab" do
    click_link "Active"
  end

  it "and we should see the active project" do
    page.should have_content "Active Project"
  end

  it "and we should not see the archived project" do
    page.should_not have_content "Inactive Project"
  end

end
