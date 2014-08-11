require 'spec_helper'
require 'capybara/email/rspec'

steps "User confirms email", :type => :feature, :js => true, :vcr => {} do

  before :all do
    VCR.use_cassette('default_vcr_cassette') do
      @user = User.create!(:email => "joe@developer.com",
        :password => "foobar",
        :password_confirmation => "foobar",
        :name => "Joe Developer",
        :login => "Codemaster")
      email = open_email('joe@developer.com')
      email.click_link('Confirm my account')
    end
  end

  it "when I go to sign in" do
    visit '/'
    within '#new_user' do
      fill_in "user_login", :with => 'Codemaster'
      fill_in "user_password", :with => 'foobar'
      click_button "Login"
    end
  end

  it "should log me in" do
    page.should have_content("Logout")
  end

end