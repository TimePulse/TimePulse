
module UnsafeMassAssignment
  # Build and create records unsafely, bypassing attr_accessible.
  # These methods are especially useful in tests and in the console.

  module ClassMethods
    def unsafe_build(attrs)
      record = new
      record.unsafe_attributes = attrs
      record
    end

    def unsafe_create(attrs)
      record = unsafe_build(attrs)
      record.save
      record
    end

    def unsafe_create!(attrs)
      record = unsafe_build(attrs)
      record.save!
      record
    end
  end

  def self.included(klass)
    klass.extend ClassMethods
  end


  def unsafe_update_attributes!(attrs)
    self.unsafe_attributes = attrs
    self.save!
  end

  def unsafe_update_attributes(attrs)
    self.unsafe_attributes = attrs
    self.save
  end

  def unsafe_attributes=(attrs)
    attrs.each do |k, v|
      send("#{k}=", v)
    end
  end
end

class ActiveRecord::Base
  include UnsafeMassAssignment
end
