# Gives the ability to cascade upward for an attribute in a nested_set
# So, for example, if a project does not have a client specified, it will
# inherit the client of its parent, or further ancestor.
module Cascade
  def self.included(klass)
    klass.extend(ClassMethods)
  end

  module ClassMethods

    def define_cascade_methods(attrib, read_method, replace_method)
      class_eval <<-EOM2, __FILE__, __LINE__
        def #{replace_method}
          if #{read_method}.blank?
            if(ancestor = ancestors.reverse.find{|a| !a.#{read_method}.blank? }).nil?
              nil
            else
              ancestor.#{read_method}
            end
          else
            #{read_method}
          end
        end

        def #{attrib}_source
          if #{read_method}.blank?
            if(ancestor = ancestors.reverse.find{|a| !a.#{read_method}.blank? }).nil?
              nil
            else
              ancestor
            end
          else
            self
          end
        end

      EOM2
    end

    def cascades(*args)
      args.each do |attrib|

        # check whether attrib is a real attribute, or some other method
        # (like, say, an association)
        if column_names.any?{|n| n==attrib.to_s}

          replace_method = attrib
          read_method = "read_attribute(:#{attrib})"
          define_cascade_methods(attrib, read_method, replace_method)

        else

          replace_method = "#{attrib}_with_cascade"
          read_method = "#{attrib}_without_cascade"

          define_cascade_methods(attrib, read_method, replace_method)
          alias_method_chain attrib, :cascade
        end
      end
    end
  end

end
