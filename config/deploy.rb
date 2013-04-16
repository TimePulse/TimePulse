$:.push "."
default_run_options[:pty] = true
#ssh_options[:verbose] = :debug
ssh_options[:auth_methods] = %w{publickey password}
ssh_options[:forward_agent] = true

# Overwrite the default deploy start/stop/restart actions with passenger ones
require 'lib/capistrano/remote_sync'
require 'lib/capistrano/passenger'
require 'capistrano/ext/multistage'
require 'bundler'
require 'bundler/capistrano'

set :sync_directories, ["public/system"]

set :stages, %w(staging production)
set :default_stage, 'production'

set :repository,  "git@github.com:LRDesign/Tracks.git"
# set :deploy_via, :remote_cache
set :scm, 'git'
set :scm_verbose, true

set :use_sudo, false

set :user,   'root'
set :runner, 'apache'
set :group,  'web'

role(:app) { domain }
role(:web) { domain }
role(:db, :primary => true) { domain }

namespace :deploy do
  task :link_shared_files do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfsT #{shared_path}/db_backups #{release_path}/db_backups"
    run "ln -sfn #{shared_path}/config/rb_password #{release_path}/config/rb_password"
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

before "deploy:assets:precompile", "deploy:link_shared_files"
