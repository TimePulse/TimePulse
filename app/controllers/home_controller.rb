class HomeController < AuthzController
  def index
    @user = current_user
    p "User's current project id in controller" => @user.current_project.id
    if (@current_project = current_user.current_project )
      @work_units = current_user.work_units_for(@current_project).order("stop_time DESC").paginate(:per_page => 10, :page => params[:page])
    end
  end
end
