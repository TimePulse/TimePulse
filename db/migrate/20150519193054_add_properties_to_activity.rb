class AddPropertiesToActivity < ActiveRecord::Migration

  class Activity < ActiveRecord::Base
  end

  def up
    add_column :activities, :properties, :hstore

    Activity.where(source:'github').each do |act|
      act.properties = {
          id: act.reference_1,
          branch: act.reference_2
      }
      act.save
    end
    Activity.where(source:'pivotal').each do |act|
      act.properties = {
          story_id: act.reference_1,
          current_state: act.reference_2,
          id: act.reference_3
      }
      act.save
    end

    remove_column :activities, :reference_1
    remove_column :activities, :reference_2
    remove_column :activities, :reference_3
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

end