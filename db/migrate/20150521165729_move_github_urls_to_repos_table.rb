class MoveGithubUrlsToReposTable < ActiveRecord::Migration

  class Project < ActiveRecord::Base
    has_many :repositories
  end

  class Repository < ActiveRecord::Base
    belongs_to :project
  end

  def up
    Project.all.each do |proj|
      Repository.create(url: proj.github_url, project_id: proj.id)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

end
