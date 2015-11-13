class RemoveGithubUrlFromProjects < ActiveRecord::Migration

  def change
    remove_column :projects, :github_url, :string
  end

end
