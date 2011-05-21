BACKUP_DIR = Rails.root + 'db_backups'

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
      purge_excess_backups(BACKUP_DIR)
    end

    # Defaults to production environment
    # call with arg like  'rake db:backups:create[development]'
    # for development (or other) environment
    desc "backup the database using mysqldump"
    task :create, :env do |t, args|
      # puts "args were #{args}"
      env = args[:env] || 'production'
      username, password, database, host  = database_config(env)
      filename = "#{database}_#{Time.now.strftime("%Y-%m-%d_%H:%M")}.sql.bz2"

      system("mkdir -p #{BACKUP_DIR}/")

      cmd = dump_command(username, password, database, host, filename)
      # puts cmd
      system(cmd)
      system "ln -sfn #{BACKUP_DIR}/#{filename} #{BACKUP_DIR}/latest.sql.bz2"
    end
  end
end

def dump_command(username, password, database, host, filename)
  sections = [ "mysqldump" ]
  sections << "-u #{username}" if username
  sections << "--password='#{password}'" if password
  sections << "-h #{host}" if host
  sections << "#{database}" if database
  sections << "| bzip2 --best > #{BACKUP_DIR}/#{filename}"
  sections.join(' ')
end

# Reads the database credentials from the local config/database.yml file
# +db+ the name of the environment to get the credentials for
# Returns username, password, database
#
def database_config(db)
  puts "database config called for #{db}"
  database = YAML::load_file('config/database.yml')
  return (database["#{db}"]['username'] || database["#{db}"]['user']), database["#{db}"]['password'], database["#{db}"]['database'], database["#{db}"]['host']
end


require 'date'

def purge_excess_backups(path)
  Dir.foreach(path) do |name|
    next if name == '.' or name == '..'

    full_name = File.join(path, name)
    #puts "#{full_name} "

    if File.ftype(full_name) == "file"
      #age = Time.now - File.mtime(full_name)
      # conjure the age of the backup from the date embedded in
      # the filename
      d = date_from_filename(name)
      unless d.nil?
        age = Time.now - date_from_filename(name)
        if(age > 1.month)     #older than one month
          #put "older than 1mo"
          File.delete(full_name)  unless first_of_month(name)
        elsif (age > 7.days)
          File.delete(full_name)  unless first_of_day(name)
        end
      end
    end
  end
end

def first_of_month(fname)
  #The backup at midnight on the first of the month
  #YYYY-MM-01_07-00
  fname =~ /\d{4}-\d{2}-01_00:0./
end

def first_of_day(fname)
  #The backup at midnight on a day
  #YYYY-MM-DD_07-00
  fname =~ /\d{4}-\d{2}-\d{2}_00:0./
end

def date_from_filename(fname)
  /(\d{4})-(\d{2})-(\d{2})_(\d{2}):(\d{2})/.match(fname)
  if $1 and $2 and $3 and $4 and $5
    Time::local($1.to_i,$2.to_i,$3.to_i,$4.to_i,$5.to_i)
  else
    nil
  end
end