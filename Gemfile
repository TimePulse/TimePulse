source 'http://rubygems.org'

gem 'rails', '~> 3.2.12'
gem 'rack'

gem 'rake'
gem "haml-rails"
gem "mizugumo"
gem "will_paginate"
gem "mysql2", "~> 0.3.10"
gem "activerecord"
gem "lrd_view_tools"
gem "logical_tabs"
gem "awesome_nested_set"
gem 'devise'
gem "chronic"
gem "logical-insight"
gem 'dynamic_form'
gem 'i18n_alchemy'
gem 'virtus'
gem 'github_api', "~> 0.11.0", :git => 'https://github.com/hannahhoward/github' #until they merge Hannah's PR
gem 'pivotal-tracker', "= 0.5.14", :git => 'https://github.com/hannahhoward/pivotal-tracker'

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'uglifier', '>= 1.0.3'

  gem 'zurb-foundation', '~> 4.0.0'
  gem 'quiet_assets'
  gem 'turbo-sprockets-rails3'
  gem 'compass-rails'
end

group :development, :test do
  gem 'rspec'
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'capybara'
  gem 'launchy'
  gem 'thin'

  # Enable for in-browser testing.  See spec/support/browser-integration.rb
  # gem 'selenium-webdriver'
  gem 'database_cleaner'
  gem 'rspec-steps'
  gem 'poltergeist'
  gem 'cadre'
  gem "populator"
  gem "faker"
end

group :test do
  gem 'simplecov', :platform => "ruby_19"
  gem 'simplecov-vim', :platform => "ruby_19"
  gem 'fuubar'
  gem 'vcr'
  gem 'fakeweb'
  gem 'timecop'
  gem "codeclimate-test-reporter", :require => nil
end

group :development do
  gem 'capistrano', '< 3.0'
  gem 'capistrano-ext'
  gem 'annotate'
  gem 'unicorn-rails'
  gem 'pivotal-github'
  gem 'debugger'
end
