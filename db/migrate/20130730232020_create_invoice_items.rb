class CreateInvoiceItems < ActiveRecord::Migration
  def change
    create_table :invoice_items do |t|
      t.string :name
      t.integer :hours
      t.integer :amount

      t.references :invoices

      t.timestamps
    end
  end
end
