class CreateInvoiceItems < ActiveRecord::Migration
  def change
    create_table :invoice_items do |t|
      t.string :name
      t.decimal :amount
      t.decimal :hours
      t.decimal :total

      t.references :invoice

      t.timestamps
    end
  end
end
