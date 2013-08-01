class AddIndexOnStopTime < ActiveRecord::Migration
  def self.up
    add_index :work_units, :stop_time
  end

  def self.down
    remove_index :work_units, :stop_time
  end
end
