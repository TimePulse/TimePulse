default_run_options[:pty] = true
ssh_options[:forward_agent] = true

# Overwrite the default deploy start/stop/restart actions with passenger ones
$:.push '.'
require 'lib/capistrano/remote_sync'
require 'lib/capistrano/passenger'
require 'lib/capistrano/set_ownership'
require 'capistrano/ext/multistage'
require 'bundler'
require 'bundler/capistrano'
set :bundle_without,  [:development, :test]

set :repository,  "git@github.com:LRDesign/TimePulse.git"
#set :deploy_via, :remote_cache
set :scm, 'git'
set :scm_verbose, true

set :stages, %w(staging production)
set :default_stage, 'staging'
set :use_sudo, false

set :user,   'root'
set :runner, 'apache'
set :group,  'web'


set :ruby_version do
  full_version = File.read(".ruby-version") rescue "2.1.2"
  /(\d+\.\d+)\.?.*/.match(full_version)[1].tap do |version|
    puts "Deploying for Ruby #{version}"
  end
end
set :bundle_cmd,    "chruby-exec #{ruby_version} -- bundle"

role(:app) { domain }
role(:web) { domain }
role(:db, :primary => true) { domain }

namespace :deploy do
  task :link_shared_files do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/db_backups #{release_path}/db_backups"
    run "ln -nfs #{shared_path}/config/initializers/secret_token.rb #{release_path}/config/initializers"
    run "ln -nfs #{shared_path}/config/initializers/smtp.rb #{release_path}/config/initializers"
    run "ln -nfs #{shared_path}/config/initializers/api_keys.rb #{release_path}/config/initializers"
    run "ln -nfs #{shared_path}/config/initializers/devise.rb #{release_path}/config/initializers"
    run "ln -nfs #{shared_path}/config/initializers/airbrake.rb #{release_path}/config/initializers"
    run "ln -nfs #{shared_path}/config/bibliotech/ #{release_path}/config/bibliotech"
  end

  task :runner_script do
    put "#!/bin/bash\nexec chruby-exec #{ruby_version} -- ${@}", "#{release_path}/cron-ruby", :mode => "+x"
  end

  task :passenger_ruby_file do
    server_ruby = capture("realpath $(chruby-exec #{ruby_version} -- which ruby)").sub(/\s*/m,'')
    htaccess_contents = "PassengerRuby #{server_ruby}"
    put htaccess_contents, "#{release_path}/.htaccess"
  end

  desc "Install the database"
  task :db_install do
     run("cd #{current_path}; /usr/bin/rake db:install RAILS_ENV=#{rails_env}")
  end

  task :cache_clear do
    run("cd #{current_path} && bundle exec rake tmp:cache:clear RAILS_ENV=#{rails_env}")
  end

end

namespace :sample_data do
  task :reload, :roles => :app do
    run "cd #{current_path} && rake db:migrate:reset RAILS_ENV=production"
    run "cd #{current_path} && rake db:sample_data:load RAILS_ENV=production "
  end
end

before "deploy:assets:precompile", "deploy:link_shared_files"
after 'deploy:update', 'deploy:runner_script'
after 'deploy:update', 'deploy:passenger_ruby_file'
after 'deploy:update', 'deploy:cleanup'
after 'deploy:update', 'deploy:cache_clear'

require './config/boot'
require 'airbrake/capistrano'
