class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.string :source
      t.datetime :time
      t.string :action
      t.text :description
      t.string :reference_1
      t.string :reference_2
      t.integer :project_id
      t.integer :work_unit_id
      t.integer :user_id

      t.timestamps
    end
  end
end
