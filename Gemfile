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
gem 'newrelic_rpm'
gem 'active_model_serializers'
gem 'bibliotech'
gem 'nested_form_fields', :git => 'https://github.com/ncri/nested_form_fields.git'
gem 'business_time'

group :assets do
  gem 'sass-rails'
  gem 'uglifier', '>= 1.0.3'

  gem 'zurb-foundation', '~> 4.0.0'
  gem 'quiet_assets'
  gem 'compass-rails'
end

group :development, :test do
  gem 'rspec', "~> 3.0.0"
  gem 'rspec-rails', "~> 3.0.0"
  gem 'rspec-legacy_formatters'
  gem 'factory_girl_rails'
  gem 'launchy'
  gem 'thin'
  gem "byebug", :platforms => [:ruby_20, :ruby_21]

  # Enable for in-browser testing.  See spec/support/browser-integration.rb
  gem 'selenium-webdriver'
  gem 'poltergeist'
  gem 'waterpig'
  gem 'cadre'
  gem "populator"
  gem "faker"
end

group :test do
  gem 'simplecov', '~> 0.7.1', :platform => "ruby_19"
  gem 'simplecov-vim', :platform => "ruby_19"
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
end
