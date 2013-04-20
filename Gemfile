gemrc = File::expand_path("~/.gemrc")
if File::exists?(gemrc)
  require 'yaml'
  conf = File::open(gemrc) {|rcfile| YAML::load(rcfile) }
  (conf[:sources] || []).grep(/lrdesign.com/).each do |server|
    source server
  end
end
source 'http://rubygems.org'

gem 'rails', '3.2.12'
gem 'rack', '~> 1.4.0'

gem 'rake'
gem "haml", ">= 3.1.2"
gem "sass-rails"
gem "mizugumo"
gem "will_paginate"
gem "populator"
gem "faker"
gem "mysql2", "~> 0.3.10"
gem "activerecord"
gem "lrd_view_tools", ">= 0.1.3"
gem "logical_tabs"
gem "awesome_nested_set"
gem 'devise'
gem 'authlogic'
gem "chronic"
gem "logical-insight"
gem 'groundworkcss-rails'
gem 'dynamic_form'

group :development, :test do
  gem 'rspec', '2.8'
  gem 'rspec-rails', '2.8'
  gem 'factory_girl_rails'
  gem 'capybara', '1.1.4'
  gem 'launchy'
  gem 'thin'
  gem 'database_cleaner'
  gem 'rspec-steps'
  gem 'debugger'
end

group :test do
  gem 'simplecov', :platform => "ruby_19"
  gem 'simplecov-vim', :platform => "ruby_19"
  gem 'fuubar'
end

group :development do
  gem 'capistrano'
  gem 'capistrano-ext'
  gem 'annotate'
  gem 'lrd_dev_tools', ">= 0.1.3"
  gem 'thin'
  gem 'pivotal-github'
end
