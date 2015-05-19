class AddPropertiesToActivity < ActiveRecord::Migration
  def change
    add_column :activities, :properties, :hstore
  end
end
