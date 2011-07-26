# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'authlogic/test_case'
require 'logical_authz/spec_helper'
require 'spec/support/authlogic_test_helper'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
#Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

require 'capybara/rspec'
require 'selenium-webdriver'
require 'rspec-steps'

Capybara.register_driver(:selenium_chrome) do |app|
  Capybara::Selenium::Driver.new(app, :browser => :chrome)
end

Capybara.default_driver = :selenium

module SaveAndOpenOnFail
  def instance_eval(&block)
    super(&block)
  rescue Object => ex
    wrapper = ex.exception("#{ex.message}\nLast view at: file://#{save_page}")
    wrapper.set_backtrace(ex.backtrace)
    raise wrapper
  end
end

RSpec.configure do |config|
  config.mock_with :rspec
  config.use_transactional_fixtures = false

  config.backtrace_clean_patterns = {}
  config.before(:each, :type => :controller, :example_group => { :example_group => "nil"})  do
    logout
  end

  config.include(SaveAndOpenOnFail, :type => :request)
end

shared_steps "for an invoicing task" do |opt_hash|
  opt_hash ||= {}
  let! :admin do
    Factory(:admin)
  end

  let! :project do
    Factory(:project)
  end

  (opt_hash[:wu_count] || 3).times do |idx|
    let! "work_unit_#{idx}" do
      Factory(:work_unit, :project => project)
    end
  end

  after do
    DatabaseCleaner.clean_with :truncation
    load 'db/seeds.rb'
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


steps "Selects all boxes", :type => :request do
  perform_steps "for an invoicing task"

  it "should select all work units" do
    click_button "select all"
  end

  it "should create the invoice" do
    named_submit = XPath.generate do |doc|
      doc.descendant(:form)[doc.attr(:id) == "new_invoice"].descendant(:input)[doc.attr(:type) == "submit"][doc.attr(:name) == "commit"]
    end
    button = find(:xpath, named_submit)
    button.click
  end

  it "should look right" do
    page.should_not have_xpath(XPath.generate do |doc|
      doc.descendant(:title)[doc.contains("Exception")]
    end.to_s)

    all(:xpath, XPath.generate do |doc|
      doc.descendant(:tr)[doc.attr(:class) == "work_unit"]
    end).should have(3).rows
  end
end

steps "Select a few work units", :type => :request do
  perform_steps "for an invoicing task", :wu_count => 5

  def click_checkbox(id)
    check(id)
  end

  it "should select 3 work units" do
    click_checkbox("invoice_work_unit_ids_1")
    click_checkbox("invoice_work_unit_ids_2")
    click_checkbox("invoice_work_unit_ids_3")
  end

  it "should create the invoice" do
    named_submit = XPath.generate do |doc|
      doc.descendant(:form)[doc.attr(:id) == "new_invoice"].descendant(:input)[doc.attr(:type) == "submit"][doc.attr(:name) == "commit"]
    end
    button = find(:xpath, named_submit)
    button.click
  end

  it "should look right" do
    page.should_not have_xpath(XPath.generate do |doc|
      doc.descendant(:title)[doc.contains("Exception")]
    end.to_s)

    all(:xpath, XPath.generate do |doc|
      doc.descendant(:tr)[doc.attr(:class) == "work_unit"]
    end).should have(3).rows
  end
end
