class ClientsAndProjects < ActiveRecord::Migration
  def self.up                       
    create_table :clients do |t|
      t.string :name
      t.string :billing_email
      t.string :address_1
      t.string :address_2
      t.string :city
      t.string :state
      t.string :postal
      t.string :abbreviation
      t.timestamps
    end
    create_table :projects do |t|
      t.references  :parent
      t.integer     :lft
      t.integer     :rgt      
      t.references  :client
      t.string      :name,            :null => false
      t.string      :account
      t.text        :description
      t.boolean     :clockable,       :null => false,  :default => false

      t.timestamps
    end    
  end

  def self.down
  end
end
