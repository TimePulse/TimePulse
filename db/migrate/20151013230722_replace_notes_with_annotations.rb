class ReplaceNotesWithAnnotations < ActiveRecord::Migration

  def change
    WorkUnit.find_each do |wu|
      Activity.create(
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
