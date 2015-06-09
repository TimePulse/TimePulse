class AddEncryptedTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :encrypted_token, :string
  end
end
