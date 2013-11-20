module UsersHelper
  def current_project
    current_user.current_project if logged_in?
  end

  def new_work_unit_for_current_project
    wu = WorkUnit.new
    wu.project = current_project
    wu
  end

end
