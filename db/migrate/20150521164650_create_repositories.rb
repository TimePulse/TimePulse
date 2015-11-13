class CreateRepositories < ActiveRecord::Migration
  def change
    create_table :repositories do |t|
      t.string :url
      t.integer :project_id

      t.timestamps
    end
  end
end
