class CalendarEventSerializer < ActiveModel::Serializer
  self.root = false
   attributes :id, :title, :start, :end, :className

   def title
    object.project.name
   end

   def start
    object.start_time
   end

   def end
    object.stop_time
   end

   def className
    "work-unit"
   end
end