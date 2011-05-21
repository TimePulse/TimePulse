class CreateWorkUnits < ActiveRecord::Migration
  def self.up
    create_table :work_units do |t|
      t.integer   :project_id
      t.integer   :user_id
      t.datetime  :start_time
      t.datetime  :stop_time
      t.decimal   :hours,     :precision => 8,  :scale => 2
      t.string    :notes

      t.references :invoice
      t.references :bill

      t.timestamps
    end
  end

  def self.down
    drop_table :work_units
  end
end
