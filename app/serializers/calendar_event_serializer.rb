class CalendarEventSerializer < ActiveModel::Serializer
  self.root = false
   attributes :id, :title, :start, :end, :className, :url
   include ProjectsHelper

   def title
    "#{project_name_with_client(object.project, short=false)} - #{object.notes}"
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

   def url
    edit_work_unit_path(object.id)
   end
end