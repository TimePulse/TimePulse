class ChangeAmountTypeInRates < ActiveRecord::Migration
  def self.up
    change_column :rates, :amount, :decimal, :precision => 8, :scale => 2
  end

  def self.down
    change_column :rates, :amount, :integer
  end
end
