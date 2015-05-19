class CalendarEventSerializer < ActiveModel::Serializer
  self.root = false
   attributes :id, :title, :start, :end, :className, :url

   def title
    "#{object.project.name} - #{object.notes}"
   end

   def start
    object.start_time
   end

   def end
    object.stop_time
   end

   def className
    object.user_id
   end

   def url
    edit_work_unit_path(object.id)
   end
end