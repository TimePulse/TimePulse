class ExpandBillsAndInvoices < ActiveRecord::Migration
  def self.up 
    add_column :bills,    :due_on, :date, :nil => false
    add_column :invoices, :due_on, :date, :nil => false
                                                       
    add_column :bills,    :paid_on,:date, :nil => true
    add_column :invoices, :paid_on,:date, :nil => true

    add_column :bills,    :reference_number, :string
    add_column :invoices, :reference_number, :string 
  end

  def self.down
    remove_column :bills,     :due_on
    remove_column :invoices,  :due_on
    remove_column :bills,     :paid_on
    remove_column :invoices,  :paid_on   
    remove_column :bills,    :reference_number
    remove_column :invoices, :reference_number     
  end
end
