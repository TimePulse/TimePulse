class AddUserAdminFlag < ActiveRecord::Migration
  def up
    add_column :users, :admin, :boolean, :default => false
  end

  def down
  end
end
