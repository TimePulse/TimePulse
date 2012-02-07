class AddArchivedToProject < ActiveRecord::Migration
  def self.up
    add_column :projects, :archived, :boolean
  end

  def self.down
    remove_column :projects, :archived
  end
end
