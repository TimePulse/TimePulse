namespace :db do
  task :only_if_undeployed  # does nothing.  # project should override this to raise once
                            # a deployment has happened, because we should stop editing migrations
                            # willy-nilly at that point

  desc "Rebuild dev and test databases from scratch, useful when editing migrations"
  task :recycle => [
    :only_if_undeployed,
    "install",
    "test:prepare",
  ]

  namespace :test do
    task :prepare do
      old_env = RAILS_ENV
      RAILS_ENV = "test"
      ENV['RAILS_ENV'] = "test"
      Rake::Task['db:load_config'].reenable
      Rake::Task['db:seed'].reenable
      Rake::Task['db:seed'].invoke
    end
  end

  desc "Build and seed the database for a new install"
  task :install => [
    :environment,
    "migrate:reset",
    "seed"
    ]
end
