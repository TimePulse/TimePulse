class AddGithubToken < ActiveRecord::Migration
  def up
    add_column :projects, :github_token, :string
  end

  def down
  end
end
