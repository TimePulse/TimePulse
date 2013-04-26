Capistrano::Configuration.instance.load do
  namespace :deploy do
    after "deploy:setup", :set_dir_ownership
    task :set_dir_ownership do
      run "chown -R #{runner}:#{group} #{deploy_to} && chmod -R g+s #{deploy_to}"
    end

    before "deploy:assets:precompile", 'deploy:set_app_ownership'
    task :set_app_ownership do
      run "chown #{runner}:#{group} #{release_path}/config/application.rb"
      run "chown #{runner}:#{group} #{shared_path}/log/*.log"
      run "chmod ug+rwx #{shared_path}/db_backups"
      run "chmod ug+rwx #{shared_path}/log"
      run "chmod 0666 #{shared_path}/log/*.log"
      make_tmp_writable
      make_sitemap_writable
      make_scripts_runnable
    end

    task :make_scripts_runnable do
      run "chown root:#{group} #{release_path}/scripts/*"
      run "chmod ug+x #{release_path}/scripts/*"
    end

    task :make_tmp_writable do
      run "chown #{runner}:#{group} #{release_path}/tmp"
      run "mkdir #{release_path}/tmp/cache"
      run "chown -R #{runner}:#{group} #{release_path}/tmp/cache"
      run "chmod -R g+rw #{release_path}/tmp"
    end

    task :make_sitemap_writable do
      file = "#{release_path}/public/sitemap.xml"
      run "touch #{file}"
      run "chown #{runner}:#{group} #{file}"
      run "chmod g+rw #{file}"
    end
  end
end
