require 'spec_helper'

steps "Admin sets a user's inactive status", :type => :feature do
  let! :user_1 do FactoryGirl.create(:user, :name => "Foo Bar 1", :inactive => false) end
  let! :user_2 do FactoryGirl.create(:user, :name => "Foo Bar 2", :inactive => true) end
  let! :admin do FactoryGirl.create(:admin) end

  it "should not allow inactive user to log in" do
    visit root_path
    fill_in "Login", :with => user_2.login
    fill_in "Password", :with => user_2.password
    click_button 'Login'
    page.should_not have_content "Logout"
  end

  it "should login as the admin" do
    fill_in "Login", :with => admin.login
    fill_in "Password", :with => admin.password
    click_button 'Login'
  end

  it "should properly set a user as inactive" do
    visit edit_user_path(user_1.id)
    page.should have_unchecked_field "user_inactive"
    check 'user_inactive'
    click_button 'Submit'
    page.should have_content "Account updated!"
    page.should have_checked_field "user_inactive"
  end

  it "should properly set a user as active" do
    visit edit_user_path(user_2.id)
    page.should have_checked_field "user_inactive"
    uncheck 'user_inactive'
    click_button 'Submit'
    page.should have_content "Account updated!"
    page.should have_unchecked_field "user_inactive"
  end
end
