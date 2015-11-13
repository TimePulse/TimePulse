class AddSourceIdToActivity < ActiveRecord::Migration
  def change
    add_column :activities, :source_id, :string
  end
end
