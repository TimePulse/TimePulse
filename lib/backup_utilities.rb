module BackupUtilities
  require 'date'

  def self.purge_excess_backups(path)
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

  def self.first_of_month(fname)
    #The backup at midnight on the first of the month
    #YYYY-MM-01_07-00
    fname =~ /\d{4}-\d{2}-01_00:0./
  end

  def self.first_of_day(fname)
    #The backup at midnight on a day
    #YYYY-MM-DD_07-00
    fname =~ /\d{4}-\d{2}-\d{2}_00:0./
  end

  def self.date_from_filename(fname)
    /(\d{4})-(\d{2})-(\d{2})_(\d{2}):(\d{2})/.match(fname)
    if $1 and $2 and $3 and $4 and $5
      Time::local($1.to_i,$2.to_i,$3.to_i,$4.to_i,$5.to_i)
    else
      nil
    end
  end
end

