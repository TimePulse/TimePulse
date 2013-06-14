class AddGithubInformation < ActiveRecord::Migration
  def up
    add_column :projects, :github_url, :string
    add_column :users, :github_user, :string
  end

  def down
  end
end
