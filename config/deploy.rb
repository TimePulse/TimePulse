default_run_options[:pty] = true
#ssh_options[:verbose] = :debug
#ssh_options[:keys] = %w{~/.ssh/lrd_rsa} # uncomment if you need to use a different key
ssh_options[:auth_methods] = %w{publickey password}
ssh_options[:forward_agent] = true

# Overwrite the default deploy start/stop/restart actions with passenger ones
require 'config/deploy/passenger'
require 'config/deploy/remote_sync'
require 'bundler/capistrano'

set :sync_directories, ["public/system"]

set :stages, %w(staging production)
set :default_stage, 'staging'
require 'capistrano/ext/multistage'

set :repository,  "git@github.com:LRDesign/REPO_NAME.git"
# set :deploy_via, :remote_cache
set :scm, 'git'
# set :git_shallow_clone, 1
set :scm_verbose, true
set :git_enable_submodules, 1


role(:app) { domain }
role(:web) { domain }
role(:db, :primary => true) { domain }

namespace :deploy do
  task :link_shared_files do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/db_backups #{release_path}/db_backups"
  end

  after 'deploy:update_code' do
    link_shared_files
  end

  desc "Recycle the database"
  task :db_install do
    logger.info "Nerfed.  See config/deploy  -JDL"
    #JDL: nerfing this cuz it can cause problems now that the app is up and
    #running
     #run("cd #{current_path}; /usr/bin/rake db:install
    #RAILS_ENV=#{rails_env}")
  end
end

namespace :sample_data do
  task :reload, :roles => :app do
    run "cd #{current_path} && rake db:migrate:reset RAILS_ENV=production"
    run "cd #{current_path} && rake db:seed RAILS_ENV=production"
    run "cd #{current_path} && rake db:sample_data:load RAILS_ENV=production "
  end
end

namespace :gems do
  desc "Install gems"
  task :install, :roles => :app do
    run "cd #{current_path} && #{sudo} rake RAILS_ENV=production gems:install"
  end
end

