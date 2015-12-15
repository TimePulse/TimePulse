require 'spec_helper'

shared_steps "for an editing task" do
  let :admin do
    FactoryGirl.create(:admin)
  end

  let :project do
    FactoryGirl.create(:project)
  end

  let :user do FactoryGirl.create(:user) end
  let! :rates_user do FactoryGirl.create(:rates_user, :rate => project.rates.last, :user => admin) end

  let! "work_units" do
    FactoryGirl.create_list(:work_unit, 3, :user => admin, :project => project)
  end

  it "should login as an admin" do
    visit root_path
    fill_in "Login", :with => admin.login
    fill_in "Password", :with => admin.password
    click_button 'Login'
    page.should have_link("Logout")
  end

end

steps "Edit a work unit from the home page", :type => :feature do
  perform_steps "for an editing task"

  it "click to edit and save a work unit" do
    page.find(:css, "#recent_work a[href='/work_units/#{work_units[0].id}/edit']").click
    click_button 'Submit'
  end

  it "should forward back to the home page" do
    page.should have_link("Logout")
    current_path.should eq(root_path)
  end
end

steps "Edit a work unit from the new invoice page", :type => :feature do
  perform_steps "for an editing task"

  it "click to edit and save a work unit" do
    click_link "Invoices"
    click_link "New Invoice"
    page.select project.client.name
    click_button "Set Parameters"
    page.find(:css, "a[href='/work_units/#{work_units[0].id}/edit']").click
    click_button 'Submit'
  end

  it "should forward back to the new invoice page" do
    page.should have_content("New Invoice")
    page.should_not have_content("Listing invoices")
  end
end
