require 'spec_helper'

steps "user logs in and edits user preferences", :type => :feature do
  let! :user do FactoryGirl.create(:user) end

  it "should successfully login" do
    visit root_path
    fill_in "Login", :with => user.login
    fill_in "Password", :with => user.password
    click_button 'Login'
    page.should have_link("Logout")
  end

  it "should click on user name" do
    click_link user.name
  end

  it "should take me to the edit account page" do
    current_path.should == edit_user_path(user)
  end

  it "should have the current user info filled in" do
    find_field("Email").value.should == user.email
    find_field("Github user").value.should == user.github_user
    find_field("Pivotal name").value.should == user.pivotal_name
  end

  it "should click on Preferences tab" do
    click_link "Preferences"
  end

  it "should change the content of the page to user preferences" do
    find_field("Recent projects count").value.should == "5"
  end

  it "should enter a new value into recent projects count" do
    fill_in "Recent projects count", with: "9"
    click_button "Submit"
  end

  it "should stay on the edit user account page" do
    current_path.should == edit_user_path(user)
  end

  it "should reflect the changes made" do
    find_field("Recent projects count").value.should == "9"
  end

end
