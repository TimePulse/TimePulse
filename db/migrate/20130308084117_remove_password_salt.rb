class RemovePasswordSalt < ActiveRecord::Migration
  def up
    remove_column :users, :crypted_password
    remove_column :users, :password_salt
  end

  def down
  end
end
