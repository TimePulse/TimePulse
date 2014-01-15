require 'spec_helper'

shared_steps "for an invoicing task" do |opt_hash|
  opt_hash ||= {}

  let :admin do
    FactoryGirl.create(:admin)
  end

  let :project do
    FactoryGirl.create(:project)
  end

  let :user do FactoryGirl.create(:user) end
  let! :rates_user do FactoryGirl.create(:rates_user, :rate => project.rates.last, :user => user) end

  (opt_hash[:wu_count] || 3).times do |idx|
    let! "work_unit_#{idx}" do
      FactoryGirl.create(:work_unit, :user => user, :project => project)
    end
  end

  it "should login as an admin" do
    visit root_path
    fill_in "Login", :with => admin.login
    fill_in "Password", :with => admin.password
    click_button 'Login'
    page.should have_link("Logout")
  end

  it "should go to invoices" do
    click_link "Invoices"
    page.should have_link("New invoice")
  end

  it "should create a new invoice for client" do
    click_link "New invoice"
    page.select project.client.name
    click_button "Set Parameters"
  end
end

steps "Delete a work unit", :type => :feature do
  perform_steps "for an invoicing task", :wu_count => 5

  it "I click the 'Delete' link for that work unit" do
    within "#work_unit_#{work_unit_0.id}" do
      click_link("Delete")
      accept_alert
    end
  end
  
  it { should_not contain("#work_unit_#{work_unit_0.id}") }
  
end