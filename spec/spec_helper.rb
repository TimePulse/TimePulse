# This file is copied to spec/ when you run 'rails generate rspec:install'
#
# NB: I had to *remove* byebug from this file. Please require it as needed: it
# breaks CI as currently configured
ENV["RAILS_ENV"] ||= 'test'

require 'simplecov'
SimpleCov.start 'rails'

if ENV["CODECLIMATE_REPO_TOKEN"]
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
end

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

require 'rspec-steps/monkeypatching'
# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

require 'selenium-webdriver'
Capybara.register_driver(:selenium_chrome) do |app|
  Capybara::Selenium::Driver.new(app, :browser => :chrome)
end
Capybara.register_driver(:selenium_firefox) do |app|
  Capybara::Selenium::Driver.new(app, :browser => :firefox)
end
Capybara.register_driver :poltergeist_debug do |app|
  Capybara::Poltergeist::Driver.new(app, :timeout => 60, :inspector => true, phantomjs_logger: Waterpig::WarningSuppressor)
end

require 'waterpig'



RSpec.configure do |config|

  #fix deprecation error, enabling both 'should' and 'expect' syntax
  config.mock_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

  config.expect_with :rspec do |expectations|
    expectations.syntax = [:should, :expect]
  end

  config.infer_spec_type_from_file_location!

  #config.backtrace_clean_patterns = {}

  config.include Devise::TestHelpers, :type => :view
  config.include Devise::TestHelpers, :type => :controller
  config.include Devise::TestHelpers, :type => :helper

  config.before(:suite) do
    %x{rake assets:precompile}
  end

  config.after(:each, :type => :view)  do
    sign_out :user
  end

  config.after(:each, :type => :controller)  do
    sign_out :user
  end

  # setup VCR to record all external requests with a single casette
  # works for everything but features
  config.around :each, :type => proc{ |value| not config.waterpig_truncation_types.include?(value)  } do |example|
    VCR.use_cassette("default_vcr_cassette") { example.call }
  end

  config.before :suite do
    File::open("log/test.log", "w") do |log|
      log.write ""
    end
  end

  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true

  config.waterpig_truncation_types = [:feature, :task]
  config.waterpig_driver =    ENV['CAPYBARA_DRIVER']    || :selenium_chrome
  config.waterpig_js_driver = ENV['CAPYBARA_JS_DRIVER'] || :selenium_chrome

  puts "Capybara driver: #{config.waterpig_driver}"

  if config.waterpig_driver.to_s == "selenium_firefox"
    config.filter_run_excluding :firefox => false
  end


  config.before :all, :type => proc{ |value| config.waterpig_truncation_types.include?(value)} do
    Rails.application.config.action_dispatch.show_exceptions = true
  end

  #JL is putting this in here - if it causes problems contact him
  require 'cadre/rspec'
  config.run_all_when_everything_filtered = true
  if config.formatters.empty?
    config.add_formatter(:progress)
  end
  config.add_formatter(Cadre::RSpec::NotifyOnCompleteFormatter)
  config.add_formatter(Cadre::RSpec::QuickfixFormatter)
end

def content_for(name)
  view.instance_variable_get("@content_for_#{name}")
end
