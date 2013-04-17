 
unless Capistrano::Configuration.respond_to?(:instance)
  abort "This extension requires Capistrano 2"
end
 
Capistrano::Configuration.instance.load do
    
  namespace :deploy do
  
    desc <<-DESC
      Restarts your application. \
      Overwrites default :restart task for Passenger server.
    DESC
    task :restart, :roles => :app, :except => { :no_release => true } do
      #passenger.restart
      run "touch #{current_path}/tmp/restart.txt"      
    end
    
    desc <<-DESC
      Starts the application servers. \
      Overwrites default :start task for Passenger server.
    DESC
    task :start, :roles => :app do
      #passenger.start
    end
    
    desc <<-DESC
      Stops the application servers. \
      Overwrites default :start task for Passenger server.
    DESC
    task :stop, :roles => :app do
      #passenger.stop
    end
    
  end

end
