class AddPivotalInformation < ActiveRecord::Migration
  def up
    add_column :projects, :pivotal_id, :integer
    add_column :users, :pivotal_name, :string
  end

  def down
  end
end
