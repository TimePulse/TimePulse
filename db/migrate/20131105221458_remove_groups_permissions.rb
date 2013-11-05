class RemoveGroupsPermissions < ActiveRecord::Migration
  def up
    User.all.each do |user|
      if user.old_admin?
        user.admin = true
        user.save
      end
    end

    drop_table :groups
    drop_table :permissions
    drop_table :groups_users
  end

  def down
  end
end
