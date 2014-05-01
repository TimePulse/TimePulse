class CreateUserPreferences < ActiveRecord::Migration
  def change
    create_table :user_preferences do |t|
      t.integer :recent_projects_count

      t.references :user

      t.timestamps
    end
    #TODO  make a UserPreferences object for each User and save it.
    # also .... each one shold start with the default value fo recent_projects_count
  end
end
