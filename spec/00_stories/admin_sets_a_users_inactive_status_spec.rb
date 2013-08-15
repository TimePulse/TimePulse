require 'spec_helper'

steps "Admin sets a user's inactive status", :type => :feature do
  let! :user_1 do Factory(:user, :name => "Foo Bar 1", :inactive => false) end
  let! :user_2 do Factory(:user, :name => "Foo Bar 2", :inactive => true) end
  let! :admin do Factory(:admin) end

  it "should login as the admin" do
    visit root_path
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
