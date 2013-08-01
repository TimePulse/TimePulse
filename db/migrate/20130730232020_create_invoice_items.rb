class CreateInvoiceItems < ActiveRecord::Migration
  def change
    create_table :invoice_items do |t|
      t.string :name
      t.float :amount
      t.float :hours
      t.float :total

      t.references :invoice

      t.timestamps
    end
  end
end
