class RemoveNotesFromWorkUnits < ActiveRecord::Migration
  def change
    remove_column :work_units, :notes, :string
  end
end
