class AddWorkUnitRefToActivities < ActiveRecord::Migration
  def change
    add_reference :activities, :work_unit, index: true
  end
end
