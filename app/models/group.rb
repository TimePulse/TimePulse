# == Schema Information
#
# Table name: groups
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Group < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name
  
  attr_accessible :name

  has_many :permissions

  has_and_belongs_to_many :users, :class_name => "User"
  alias members users 

  # returns true if this group can do *action* on *controller* optional object
  def can?(action, controller, object = nil)
    conditions = {
      :group => self,
      :controller => controller,
      :action => action,
      :id => object.id
    }                   
    return LogicalAuthz::is_authorized?(conditions)
  end
  
  class << self
    def admin_group
      self.find_by_name("Administration")
    end  

    def member_class
      User
    end
  end

end
