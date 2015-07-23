class MoveIdsFromPropertiesToSourceId < ActiveRecord::Migration
  class Activity < ActiveRecord::Base
  end

  def up
    Activity.all.each do |act|
      act.source_id = act.properties["id"]
      act.properties.delete("id")
      act.save
    end
  end
  
  def down
    Activity.all.each do |act|
      if act.source_id
        act.properties["id"] = act.source_id
        act.save
      end
    end
  end

end
