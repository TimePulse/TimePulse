source 'http://rubygems.org'

gem 'rails', '~> 4.0.3'
gem 'rack'

gem 'rake'
gem "haml-rails"
gem "mizugumo"
gem "will_paginate"
gem 'pg'
#gem 'mysql2', '~> 0.3.10'
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
gem 'pivotal-tracker', "= 0.5.14", :git => 'https://github.com/hannahhoward/pivotal-tracker'
gem 'newrelic_rpm'
gem 'active_model_serializers'

#for Rails 4 transition
gem 'protected_attributes'
gem 'rails-observers'
gem 'actionpack-page_caching'
gem 'actionpack-action_caching'

group :assets do
  gem 'sass-rails',   '~> 4.0'
  gem 'uglifier', '>= 1.0.3'

  gem 'zurb-foundation', '~> 4.0.0'
  gem 'quiet_assets'
  gem 'compass-rails'
end

group :development, :test do
  gem 'rspec', "~> 2.13.0"
  gem 'rspec-rails', "~> 2.13.0"
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
  gem "byebug"
end

group :test do
  gem 'simplecov', :platform => "ruby_19"
  gem 'simplecov-vim', :platform => "ruby_19"
  gem 'fuubar', "~> 1.2.1"
  gem 'vcr'
  gem 'fakeweb'
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
