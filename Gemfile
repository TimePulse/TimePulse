gemrc = File::expand_path("~/.gemrc")
if File::exists?(gemrc)
  require 'yaml'
  conf = File::open(gemrc) {|rcfile| YAML::load(rcfile) }
  (conf[:sources] || []).grep(/lrdesign.com/).each do |server|
    source server
  end
end
source 'http://rubygems.org'

gem 'rails', '3.0.7'

gem "haml"
gem "sass"
gem "mizugumo"
gem "will_paginate", "~> 3.0.pre2"
gem "populator"
gem "faker"
gem "mysql2", "< 0.3"
gem "activerecord"
gem "lrd_view_tools", ">= 0.1.3"
gem "lrd_rack_bug", ">= 0.3.0.4"
# gem "logical_authz"
gem "awesome_nested_set"
gem 'authlogic', :git => 'git://github.com/odorcicd/authlogic.git', :branch => 'rails3'


group :development, :test do
  gem 'rspec'
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'webrat'
  gem 'ruby-debug'
end

group :development do
  gem 'annotate'
  gem 'lrd_dev_tools', ">= 0.1.1"
  gem 'mongrel'
end
