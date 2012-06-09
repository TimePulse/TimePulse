gemrc = File::expand_path("~/.gemrc")
if File::exists?(gemrc)
  require 'yaml'
  conf = File::open(gemrc) {|rcfile| YAML::load(rcfile) }
  (conf[:sources] || []).grep(/lrdesign.com/).each do |server|
    source server
  end
end
source 'http://rubygems.org'

gem 'rails', '3.0.10'
gem 'rack', '1.2.1'

gem 'rake', '0.8.7'
gem "haml", ">= 3.1.2"
gem "sass"
gem "mizugumo"#, :path => "../mizugumo/"
gem "will_paginate", "~> 3.0.pre2"
gem "populator"
gem "faker"
gem "mysql2", "< 0.3"
gem "activerecord"
gem "lrd_view_tools", ">= 0.1.3"
gem "logical_tabs"
gem "awesome_nested_set"
gem 'authlogic', :git => 'git://github.com/odorcicd/authlogic.git', :branch => 'rails3'
gem 'logical_authz' #, :path => "../LogicalAuthz/"
gem "chronic"

group :development, :test do
  gem "logical-insight"
  gem 'rspec', "< 2.8"
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'ruby-debug', :platform => "ruby_18"
  gem 'ruby-debug19', :platform => "ruby_19"
  gem 'capybara'
  gem 'launchy'
  gem 'thin'
  gem 'database_cleaner'
  gem 'rspec-steps'
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
end
