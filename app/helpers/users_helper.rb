module UsersHelper
  def current_project
    current_user.current_project if logged_in?
  end
end
