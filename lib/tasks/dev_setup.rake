namespace :dev do


  # USAGE: rake dev:reset_all_passwords PASSWORD=pppp
  desc "Reset all passwords to 'password' or whatever you want (use PASSWORD=foo)"
  task :reset_all_passwords => [:environment] do
    pwd = ENV['PASSWORD'] || 'password'

    return unless RAILS_ENV == 'development'

    user = User.first
    user.password = pwd
    user.password_confirmation = pwd
    user.save!
    user.reload

    sql = "UPDATE users SET crypted_password = '#{user.crypted_password}', password_salt = '#{user.password_salt}'"
    User.connection.execute sql
    puts "All passwords are now '#{pwd}'"
  end

  desc "Resets a single user's password to [PASSWORD] (default: 'password')"
  task :reset_password, [:user, :password] => [:environment] do |task, args|
    user = User.find_by_login(args[:user])
    password = args[:password] || "password"
    user.password = password
    user.password_confirmation = password
    user.save!
    puts "Password for #{user.preferred_email.address} (#{user.id}) is now #{password.inspect}"
  end

  desc "Set up sensitive files (database.yml etc.)for local development"
  task :config_files  do
    root = Rails.root
    [ 'database.yml', 'initializers/smtp.rb', 'initializers/secret_token.rb'].each do |file|
      sh "cp #{root}/config/#{file}.example #{root}/config/#{file}"
    end
  end

end
