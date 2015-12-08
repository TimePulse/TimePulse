class AddUniqueIndexToActivity < ActiveRecord::Migration
  def change
    add_index(:activities, [:project_id, :source, :source_id], unique: true, name: 'by_source_source_id_and_project')
  end
end
