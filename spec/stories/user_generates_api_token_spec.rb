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

  it "should click on 'API Token' tab" do
    click_link "API Token"
  end

  it "should have a generate token button" do
    page.should have_button("Generate API Token")
  end

  it "when I click on generate api token button" do
    click_button "Generate API Token"
  end

  it "should display the unencrypted token" do
    page.should have_content("Here is your API token")
  end


end
