class SetArchivedDefaultToFalse < ActiveRecord::Migration
  def change
    change_column_default :projects, :archived, false
  end

  Project.where(archived: nil).each do |project|
    project.archived = false
    project.save
  end
end
