BACKUP_DIR = Rails.root + 'db_backups'
require 'mysql_commands'
require 'database_config'
require 'backup_utilities'

module DatabaseCommands
  include MysqlCommands
end

namespace :db do
  namespace :backups do


    # Defaults to production environment
    # call with arg like  'rake db:backups:cycle[development]'
    # for development (or other) environment
    desc "Create a new backup and purge old ones"
    task :cycle, [ :env ] => [
      "db:backups:create",
      "db:backups:purge"
    ]

    desc "Remove excess backups, keeping hourlies for 3 days and dailies for one month"
    task :purge do
      BackupUtilities.purge_excess_backups(BACKUP_DIR)
    end

    # Defaults to production environment
    # call with arg like  'rake db:backups:create[development]'
    # for development (or other) environment
    desc "backup the database"
    task :create, [:dir, :filename] do |t, args|
      env = ENV['RAILS_ENV'] || 'development'
      db_config = DatabaseConfig::read
      dir = args[:dir] || BACKUP_DIR

      if args[:filename]
        backup_path = "#{dir}/#{args[:filename]}"
      else
        backup_path = "#{dir}/#{db_config['database']}_#{Time.now.strftime("%Y-%m-%d_%H:%M")}.sql.bz2"
      end

      system("mkdir -p #{dir}/")

      cmd = DatabaseCommands.backup_command(db_config, backup_path)
      puts "Backup Command:\n#{cmd}"
      system(cmd)
      system "ln -sfn #{backup_path} #{dir}/latest.sql.bz2"
    end

        # defaults to development enviroment
    # call with env like  'RAILS_ENV=production rake db:backups:restore'
    # for production (or other) environment
    desc 'restore the database backup, defaults to development db'
    task :restore, [:filename] do |t, args|
      env = ENV['RAILS_ENV'] || 'development'
      db_config = DatabaseConfig.read
      filename = args[:filename] || ENV['BACKUP_FILE']

      # If a name wasn't passed, try to use the most recent backup in the
      # standard dir.
      unless filename
        filename = "#{BACKUP_DIR}/" + Dir.new(BACKUP_DIR).find { |f| ['latest.sql.bz2', 'latest.sql'].include?(f) }
      end
      tempfile = uncompress_to_tempfile(filename) if filename =~ /\.bz2\z/
      cmd = DatabaseCommands.restore_backup_command(db_config, tempfile.try(:path) || filename)
      puts "Running command: " + cmd
      system(cmd)
      tempfile.unlink if  defined?(tempfile)
    end

    desc "Restores the latest.sql.bz2 from the production (symlink) directory"
    task :restore_from_production do
      Rake::Task[:restore].invoke('production/current/db_backups/latest.sql.bz2')
    end

    def uncompress_to_tempfile(filename)
      require 'pathname'
      filename = Pathname.new(filename).realpath

      # uncompress to a temp file, if it's gzipped
      if filename.to_s =~ /\.bz2$/
       tmpfile = Tempfile.new('db')
       system "bunzip2 -c #{filename} > #{tmpfile.path}"
      end
      tmpfile
    end
  end
end


