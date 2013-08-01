# == Schema Information
#
# Table name: invoices
#
#  id               :integer(4)      not null, primary key
#  client_id        :integer(4)
#  notes            :text
#  created_at       :datetime
#  updated_at       :datetime
#  due_on           :date
#  paid_on          :date
#  reference_number :string(255)
#

class Invoice < ActiveRecord::Base
  include I18n::Alchemy
  belongs_to :client
  has_many :work_units
  has_many :invoice_items, :autosave => true, :dependent => :destroy

  validates_presence_of :client_id

  scope :overdue, lambda { { :conditions => [ "paid_on IS NULL AND due_on < ? ", Date.today ] } }
  scope :unpaid,  :conditions => { :paid_on => nil }
  scope :paid, :conditions => "paid_on IS NOT NULL"

  attr_accessible :notes, :due_on, :client, :client_id, :paid_on, :reference_number
  accepts_nested_attributes_for :work_units, :reject_if => :all_blank, :allow_destroy => :false

  before_save :generate_invoice_items, :if => :new_record?
  before_destroy :dissociate_work_units

  # TODO: Reimplement this with i18n
  # attr_human_name :reference_number => 'Ref #'

  def hours
    work_units.sum(:hours)
  end

  def paid?
    !paid_on.nil?
  end

  private

  def generate_invoice_items
    client_project = Project.where(:client_id => client.id, :parent_id => Project.root.id).first
    if client_project.nil?
      errors.add :invoice_units, "This client has no projects."
      return false
    end

    items = {}
    rates = client_project.rates
    rates.each do |rate|
      items[rate.id] = { :name => rate.name, :hours => 0.0, :amount => rate.amount.to_f, :total => 0.0 }
    end

    self.work_units.each do |wu|
      user_rate = wu.user.rate_for(client_project)
      if item = items[user_rate.id]
        item[:hours] += wu.hours
        item[:total] += wu.hours * item[:amount]
      else
        errors.add :invoice_units, "There is no rate assigned to #{wu.user.name} for this client."
        return false
      end
    end

    items.values.each do |item|
      invoice_item = InvoiceItem.create
      invoice_item.name = item[:name]
      invoice_item.hours = item[:hours]
      invoice_item.amount = item[:amount]
      invoice_item.total = item[:total]
      invoice_items << invoice_item
    end
  end

  def dissociate_work_units
    self.work_units.each do |wu|
      wu.invoice = nil
      wu.save
    end
  end

end
