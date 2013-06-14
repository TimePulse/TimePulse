# Gives the ability to cascade upward for an attribute in a nested_set
# So, for example, if a project does not have a client specified, it will
# inherit the client of its parent, or further ancestor.
module Cascade
  def self.included(klass)
    klass.extend(ClassMethods)
  end  
              
  module ClassMethods             
    def cascades(*args)
      args.each do |attrib|                       
         
        # check whether attrib is a real attribute, or some other method
        # (like, say, an association)
        if column_names.any?{|n| n==attrib.to_s} 
          
          # for true attributes, use this version
          class_eval <<-EOM, __FILE__, __LINE__
          def #{attrib}
            if read_attribute(:#{attrib}).blank?
              if(ancestor = ancestors.reverse.find{|a| !a.read_attribute(:#{attrib}).blank? }).nil?
                nil
              else
                ancestor.read_attribute(:#{attrib})
              end
            else       
              read_attribute(:#{attrib})
            end
          end

          def #{attrib}_source
            if read_attribute(:#{attrib}).blank?
              if(ancestor = ancestors.reverse.find{|a| !a.read_attribute(:#{attrib}).blank? }).nil?
                nil
              else
                ancestor
              end
            else       
              self
            end
          end

          EOM
        else
          
          # for associations and other methods, use this version
          class_eval <<-EOM2, __FILE__, __LINE__
          def #{attrib}_with_cascade
            if #{attrib}_without_cascade.blank?
              if(ancestor = ancestors.reverse.find{|a| !a.#{attrib}_without_cascade.blank? }).nil?
                nil
              else                
                ancestor.#{attrib}_without_cascade
              end
            else   
              #{attrib}_without_cascade
            end
          end

          def #{attrib}_source
            if #{attrib}_without_cascade.blank?
              if(ancestor = ancestors.reverse.find{|a| !a.#{attrib}_without_cascade.blank? }).nil?
                nil
              else                
                ancestor
              end
            else   
              self
            end
          end   
                                           
          EOM2
          alias_method_chain attrib, :cascade
        end
      end  
    end  
  end
    
end
