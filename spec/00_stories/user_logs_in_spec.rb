require 'spec_helper'

steps "user login", :type => :feature do
  let! :user do Factory(:user) end
  
  it "should accept username" do
    visit root_path
    fill_in "Login", :with => user.login
    fill_in "Password", :with => user.password
    click_button 'Login'
    page.should have_link("Logout")
  end

  it "should accept email" do
    click_link 'Logout'
    fill_in "Login", :with => user.email
    fill_in "Password", :with => user.password
    click_button 'Login'
    page.should have_link("Logout")
  end
end

