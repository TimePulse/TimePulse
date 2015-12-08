namespace :activities do
  desc "Attempts to find associated work units for activities recorded in the prior 24 hours"
  task :associate_orphans do
    OrphanActivityAssociator.new(Time.now - 24.hours).run
  end
end
