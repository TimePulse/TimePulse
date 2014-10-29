set :ruby_version do
  full_version = File.read(".ruby-version") rescue "2.1.2"
  /(\d+\.\d+)\.?.*/.match(full_version)[1].tap do |version|
    puts "Deploying for Ruby #{version}"
  end
end
set :bundle_cmd,    "chruby-exec #{ruby_version} -- bundle"

namespace :deploy do
  task :runner_script do
    put "#!/bin/bash\nexec chruby-exec #{ruby_version} -- ${@}\n", "#{release_path}/cron-ruby", :mode => "+x"
  end

  task :passenger_ruby_file do
    server_ruby = capture("realpath $(chruby-exec #{ruby_version} -- which ruby)").sub(/\s*/m,'')
    htaccess_contents = "PassengerRuby #{server_ruby}"
    put htaccess_contents, "#{release_path}/.htaccess"
  end
end

after 'deploy:update', 'deploy:runner_script'
after 'deploy:update', 'deploy:passenger_ruby_file'
