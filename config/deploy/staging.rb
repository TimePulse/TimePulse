set :runner, 'apache'
set :user, 'root'

set :domain, 'appserver2.lrdesign.com'
set :application, 'tracks-staging'      # eg 'rfx'
set :deploy_to, '/var/www/tracks-staging.lrdesign.com'

set :keep_releases, 5
set :branch, 'staging'
set :rails_env, "staging"
set :use_sudo, false

namespace :deploy do
  task :link_production, :on_error => :continue do
    run "ln -sfn #{shared_path}/production #{release_path}/production"
  end

  task :db_sync, :on_error => :continue do
    run "cd #{current_path} && bundle exec rake db:backups:restore_from_production RAILS_ENV=staging"
  end

  task :asset_sync do
    #This is intentionally agnostic about the shared symlinks"
    run "cd #{shared_path} && rsync --archive --keep-dirlinks --verbose ~/rfx.com/shared/system/ system"
  end

  task :go_away_robots, :on_error => :continue do
    run "cp #{shared_path}/robots.txt #{release_path}/public/robots.txt"
  end
end

after "deploy:update_code", "deploy:link_production"
after "deploy:link_production", "deploy:db_sync"
after "deploy:symlink", "deploy:go_away_robots"
