class RemoveDefultFromWorkUnitsBillable < ActiveRecord::Migration
  def up
    change_column :work_units, :billable, :boolean, :default => nil
  end

  def down
    change_column :work_units, :billable, :boolean, :default => true
  end
end
