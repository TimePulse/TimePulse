class AddFlagsToProjectsAndWorkUnits < ActiveRecord::Migration
  def self.up    
    add_column :projects, :billable, :boolean, :nil => false, :default => true
    add_column :projects, :flat_rate, :boolean, :nil => false, :default => false
    add_column :work_units, :billable, :boolean, :nil => false, :default => true
  end

  def self.down
  end
end
