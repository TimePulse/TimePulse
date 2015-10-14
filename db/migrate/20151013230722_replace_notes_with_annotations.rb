class ReplaceNotesWithAnnotations < ActiveRecord::Migration
  class MigrationActivity < ActiveRecord::Base
    self.table_name = :activities
  end
  class MigrationWorkUnit < ActiveRecord::Base
    self.table_name = :work_units
  end

  def change
    MigrationWorkUnit.find_each do |wu|
      MigrationActivity.create(
        :source => 'User',
        :action => 'Annotation',
        :description => wu.notes,
        :user_id => wu.user_id,
        :project_id => wu.project_id,
        :work_unit_id => wu.id
      )
    end
  end
end