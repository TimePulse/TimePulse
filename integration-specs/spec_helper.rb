# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'authlogic/test_case'
require 'logical_authz/spec_helper'
require 'spec/support/authlogic_test_helper'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("integration-specs/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rspec
  config.use_transactional_fixtures = false

  config.backtrace_clean_patterns = {}
  config.before(:each, :type => :controller, :example_group => { :example_group => "nil"})  do
    logout
  end

  config.before :all, :type => :request do
    Rails.application.config.action_dispatch.show_exceptions = true
  end

  config.after :all, :type => :request do
    DatabaseCleaner.clean_with :truncation
    load 'db/seeds.rb'
  end

  config.before :suite do
    DatabaseCleaner.clean_with :truncation
    load 'db/seeds.rb'
  end

  config.include(SaveAndOpenOnFail, :type => :request)
end
