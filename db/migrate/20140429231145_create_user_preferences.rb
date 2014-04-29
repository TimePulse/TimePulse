class CreateUserPreferences < ActiveRecord::Migration
  def change
    create_table :user_preferences do |t|
      t.integer :recent_projects_count

      t.references :user

      t.timestamps
    end
  end
end
