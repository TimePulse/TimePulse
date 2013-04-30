class ConvertUsersTableToDevise < ActiveRecord::Migration
  def up
    add_column :users, :encrypted_password, :string
    remove_column :users, :crypted_password
    remove_column :users, :password_salt

    User.all.each do |u|
        u.password = "resetme"
        u.password_confirmation = "resetme"
        u.save
    end

    add_column :users, :confirmation_token, :string, :limit => 255
    add_column :users, :confirmed_at, :timestamp
    add_column :users, :confirmation_sent_at, :timestamp
    execute "UPDATE users SET confirmed_at = created_at, confirmation_sent_at = created_at"
    add_column :users, :reset_password_token, :string, :limit => 255
    add_column :users, :reset_password_sent_at, :timestamp
    add_column :users, :remember_token, :string, :limit => 255
    add_column :users, :remember_created_at, :timestamp
    rename_column :users, :login_count, :sign_in_count
    rename_column :users, :current_login_at, :current_sign_in_at
    rename_column :users, :last_login_at, :last_sign_in_at
    rename_column :users, :current_login_ip, :current_sign_in_ip
    rename_column :users, :last_login_ip, :last_sign_in_ip

    rename_column :users, :failed_login_count, :failed_attempts
    add_column :users, :unlock_token, :string, :limit => 255
    add_column :users, :locked_at, :timestamp
    add_column :users, :unconfirmed_email, :string

    remove_column :users, :persistence_token
    remove_column :users, :perishable_token
    remove_column :users, :single_access_token

    add_index :users, :email,                :unique => true
    add_index :users, :confirmation_token,   :unique => true
    add_index :users, :reset_password_token, :unique => true
    add_index :users, :unlock_token,         :unique => true
  end

  def down
  end
end
