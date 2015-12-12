source 'http://rubygems.org'

gem 'rails', '~> 4.1.0'
gem 'rack'
gem 'pg'

gem 'rake'
gem "haml-rails"
gem "mizugumo"
gem "will_paginate"
gem "activerecord"
gem "lrd_view_tools"
gem "logical_tabs"
gem "awesome_nested_set", :github => "collectiveidea/awesome_nested_set"
gem 'devise'
gem "chronic"
gem "logical-insight"
gem 'dynamic_form'
gem 'i18n_alchemy'
gem 'virtus'
gem 'github_api', "~> 0.11.1"
gem 'lrd-pivotal-tracker', "= 0.5.14"
gem 'active_model_serializers'
gem 'bibliotech'
gem 'nested_form_fields', :git => 'https://github.com/ncri/nested_form_fields.git'
gem 'business_time'
gem 'psych', ">= 2.0.15"
gem 'airbrake'

group :production do
  gem 'newrelic_rpm'
end

group :assets do
  gem 'sass-rails'
  gem 'uglifier', '>= 1.0.3'

  gem 'foundation-rails'
  gem 'quiet_assets'
  gem 'compass-rails', '>= 2.0.2'
end

group :development, :test do
  gem 'rspec', "3.0.0"
  gem 'rspec-rails'#, "3.0.0"
  gem 'rspec-legacy_formatters'
  gem 'rspec-collection_matchers'
  gem 'factory_girl_rails'
  gem 'thin'

  # Enable for in-browser testing.  See spec/support/browser-integration.rb
  gem 'capybara-webkit', '~> 1.7.0'
  gem 'selenium-webdriver'
  gem 'poltergeist'
  gem 'waterpig', "~> 0.12.1"
  gem 'cadre'
  gem "populator"
  gem "faker"
end

group :test do
  gem 'simplecov', '~> 0.7.1'
  gem 'simplecov-vim'
  gem 'rspec-its'
  gem 'fuubar'
  gem 'vcr'
  gem 'webmock'
  gem 'timecop'
  gem "codeclimate-test-reporter", :require => nil
  gem 'json_spec'
end

group :development do
  gem 'capistrano', '< 3.0'
  gem 'capistrano-ext'
  gem 'annotate'
  gem 'unicorn-rails'
  gem 'pivotal-github'
  gem 'launchy'
end

group :debug do
  gem "byebug"
end
