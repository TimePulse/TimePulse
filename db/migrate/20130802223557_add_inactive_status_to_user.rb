class AddInactiveStatusToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :inactive, :boolean, :default => false
  end

  def self.down
    remove_column :users, :inactive
  end
end
