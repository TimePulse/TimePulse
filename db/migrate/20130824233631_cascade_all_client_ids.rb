class CascadeAllClientIds < ActiveRecord::Migration
  def up
    projects = Project.find(:all)
    projects.each do |p|
      #simply saving each project should be sufficient to invoke client_id cascading properly
      p.save
    end
  end

  def down
  end
end
