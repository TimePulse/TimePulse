require 'spec_helper'

steps "Admin views the hours reports", :type => :feature do
  let! :user_1 do FactoryGirl.create(:user, :name => "Foo Bar 1", :inactive => false) end
  let! :user_2 do FactoryGirl.create(:user, :name => "Foo Bar 2", :inactive => true) end
  let! :admin do FactoryGirl.create(:admin) end

    it "should login as the admin" do
      visit root_path
      fill_in "Login", :with => admin.login
      fill_in "Password", :with => admin.password
      click_button 'Login'
    end

    it "should click the hours reports" do
      click_link 'Hours Reports'
    end

    it "should navigate to hours reports view" do
      current_path.should eq(hours_reports_path)
    end

end
