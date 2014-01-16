module ProjectReportsHelper
  def project_report_selector()
    if @client
      select_tag( :client_id, options_for_select(project_selector_array_with_hours, @client.id), { :include_blank => "", :class => "project-report-selector" })
    else
      select_tag( :client_id, options_for_select(project_selector_array_with_hours), { :include_blank => "", :class => "project-report-selector"  })
    end
  end

  def project_selector_array_with_hours
    @project_array ||= Project.find(:all).collect{ |p| [
       "#{p.name} - (#{WorkUnit.for_project(p).uninvoiced.completed.billable.sum(:hours)}) ",
       p.id
    ]}
  end

end