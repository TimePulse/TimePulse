class CreateRates < ActiveRecord::Migration
  def change
    create_table :rates do |t|
      t.string :name, :null => false
      t.integer :amount, :null => false

      t.references :project

      t.timestamps
    end

    create_table :rates_users, :index => false do |t|
      t.references :rate
      t.references :user
    end
  end
end
