module UsersHelper
  def current_project
    current_user.current_project if logged_in?
  end

  def work_unit_cache_key_for_user
    user   = current_user.name
    userid = current_user.id
    "work_units_for_user_#{userid}:_#{user}"
  end
end
