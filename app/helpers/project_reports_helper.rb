module ProjectReportsHelper

  def project_report_selector
    select_tag(:project_id, options_for_select(project_options), { :include_blank => "", :class => "project_selector"})
  end

  def user_project_hours(work_units)
    #byebug
    user_hours = {}
    work_units.each do |wu|
      user_hours[wu.user] ||= 0.0
      user_hours[wu.user] += wu.hours
    end
    user_hours["Total"] = user_hours.values.reduce(0){ |sum, wu| sum += wu }
    user_hours
  end

  def report_title
    if @project
      @project.name
    else
      "Report Parameters"
    end
  end
end
