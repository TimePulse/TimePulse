module ProjectReportsHelper
  
  def project_report_selector
    select_tag(:project_id, options_for_select(project_options), { :include_blank => "", :class => "project_selector"})
  end

  def user_project_hours
    total = 0
    @user_hours = []
    @work_units.each do |wu|
      in_list = false
      user = User.find_by_id(wu.user_id)
      
      @user_hours.each do |uh|
        if user.name == uh[0]
          in_list = true
          uh[1] += wu.hours
          break
        end
      end
      
      if in_list == false
        @user_hours.push([user.name, wu.hours])
      end
      
      total += wu.hours
      
    end
    
    @user_hours.push(["Total", total])
    
    return @user_hours
  end
  
  def report_title
    if @project
      @project.name
    else
      "Report Parameters"
    end
  end
end
