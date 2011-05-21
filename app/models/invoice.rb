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
  belongs_to :client
  has_many :work_units

  validates_presence_of :client_id

  scope :overdue, lambda { { :conditions => [ "paid_on IS NULL AND due_on < ? ", Date.today ] } }
  scope :unpaid,  :conditions => { :paid_on => nil }
  scope :paid, :conditions => "paid_on IS NOT NULL"

  attr_accessible :notes, :due_on, :client, :client_id, :paid_on, :reference_number
  accepts_nested_attributes_for :work_units, :reject_if => :all_blank, :allow_destroy => :false

  # TODO: Reimplement this with i18n
  # attr_human_name :reference_number => 'Ref #'

  def hours
    work_units.sum(:hours)
  end

  def paid?
    !paid_on.nil?
  end

end
