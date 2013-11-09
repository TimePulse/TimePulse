class RemoveGroupsPermissions < ActiveRecord::Migration
  def up
    drop_table :groups
    drop_table :permissions
    drop_table :groups_users
  end

  def down
  end
end
