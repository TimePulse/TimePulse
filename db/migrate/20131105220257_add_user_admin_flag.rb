class AddUserAdminFlag < ActiveRecord::Migration
  def up
    add_column :users, :admin, :boolean, :default => false
    User.all.each do |user|
      if user.old_admin?
        user.admin = true
        user.save
      end
    end

  end

  def down
  end
end
