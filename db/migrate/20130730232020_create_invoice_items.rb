class CreateInvoiceItems < ActiveRecord::Migration
  def change
    create_table :invoice_items do |t|
      t.string :name
      t.decimal :amount, :precision => 8, :scale => 2
      t.decimal :hours, :precision => 8, :scale => 2
      t.decimal :total, :precision => 8, :scale => 2

      t.references :invoice

      t.timestamps
    end
  end
end
