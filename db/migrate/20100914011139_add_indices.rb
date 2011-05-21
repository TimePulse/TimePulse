class AddIndices < ActiveRecord::Migration
  def self.up    
    add_index :work_units, :user_id
    add_index :work_units, [:hours, :start_time]     
    add_index :groups, :name
    add_index :projects, :lft
    add_index :projects, [:lft, :rgt]   
    add_index :projects, [:parent_id, :lft]
    add_index :groups_users, [:group_id, :user_id]
    add_index :projects, [:client_id]     
    add_index :work_units, :bill_id
    add_index :work_units, :invoice_id
    
  end

  def self.down
    remove_index :work_units, :user_id
    remove_index :work_units, [:hours, :start_time]     
    remove_index :groups, :name   
    remove_index :projects, :lft
    remove_index :projects, [:lft, :rgt]   
    remove_index :projects, [:parent_id, :lft]
    remove_index :groups_users, [:group_id, :user_id]
    remove_index :projects, [:client_id]    
    remove_index :work_units, :bill_id
    remove_index :work_units, :invoice_id    
  end
end
