class RemoveActivityWorkUnit < ActiveRecord::Migration
  def up
    remove_column :activities, :work_unit_id
  end

  def down
  end
end
