class InvoicesAndBills < ActiveRecord::Migration
  def self.up      
    # Invoices are lists of work logs for a client, compiled and
    # invoiced to that client.
    create_table :invoices do |t|  
      t.references :client
      t.text     :notes
      t.timestamps
    end                     
    
    # Bills are lists of work logs performed by a user/developer,
    # compiled and entered into company accounting as a bill.
    create_table :bills do |t|  
      t.references :user
      t.text       :notes
      t.timestamps
    end      
    
  end

  def self.down
  end
end
