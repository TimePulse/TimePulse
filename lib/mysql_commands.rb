module MysqlCommands

  module ModuleMethods
    def backup_command(config, destination)
      parts = [ "mysqldump" ]
      parts += command_parts(config)
      parts += [ "| bzip2 --best > #{destination}" ]
      parts.join(' ')
    end

    # RESTORE FULL DATABASE
    #pg_restore -h lrd-dev -U postgres -d thefriendex_dev db_backups/frx.pg
    def restore_backup_command(config, source_file)
      parts = [ 'cat', source_file, '|']
      parts << "mysql"
      parts += command_parts(config)
      parts.join(' ')
    end

    def command_parts(config)
      parts = [ ]
      parts << "-u #{config['username']}" if config['username']
      parts << "--password='#{config['password']}'" if config['password']
      parts << "-h #{config['host']}" if config['host']
      parts << "#{config['database']}" if config['database']
      parts
    end
  end
  extend ModuleMethods

  def self.included(other)
    other.extend(ModuleMethods)
  end
end



