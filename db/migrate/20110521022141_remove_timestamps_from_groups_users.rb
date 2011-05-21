class RemoveTimestampsFromGroupsUsers < ActiveRecord::Migration
  def self.up
    remove_column :groups_users,     :updated_at
    remove_column :groups_users,     :created_at
  end

  def self.down
    add_column :groups_users,     :updated_at, :datetime
    add_column :groups_users,     :created_at, :datetime
  end
end
