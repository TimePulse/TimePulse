module WorkUnitsHelper
  def clocked_in?
    current_user.clocked_in? if current_user
  end

  def current_work_unit
    current_user.current_work_unit if current_user
  end


  TOOLTIP_FIELDS = [
    [ :project, "short_name_with_client(work_unit.project)" ],
    [ :notes, "work_unit.notes" ],
    [ :hours, "work_unit.hours" ],
    [ :started, "work_unit.start_time.to_s(:date_and_time)" ],
    [ :finished, "work_unit.stop_time.to_s(:date_and_time)" ],
    [ nil, "widget_links(work_unit)" ]
  ]
  def tooltip_for(work_unit, token)                        
    content_tag( :div, :id => "tooltip_for_#{token}", :class => "tooltip") do
      TOOLTIP_FIELDS.map { |pair| 
        content_tag(:p) do
          content_tag(:b, format_title(pair[0])) + eval(pair[1]).to_s
        end        
      }.join()
    end.html_safe!
  end  

  def format_title(title)    
    if title
      title.to_s.titleize + ": "
    else
      ""
    end
  end
  
  def widget_links(work_unit)
    link_to( 'Edit', edit_work_unit_path(work_unit)) + " " +
    link_to('Delete', work_unit_path(work_unit), {:method => :delete, :confirm => "Are you sure?"})
  end
  
end
