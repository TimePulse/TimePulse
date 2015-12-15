require 'spec_helper'

RSpec.shared_steps "log in" do

  it "When I go to the login page" do
    # TODO: figure out why this doesn't work.
    visit '/login'
  end

  it "should fill in the user's information user" do
    the_user = user or FactoryGirl.create(:user)
    fill_in "Login", :with => the_user.login
    fill_in "Password", :with => the_user.password
    click_button 'Login'
  end

  it "should result in a logged-in page" do
    page.should have_link("Logout")
  end

end
