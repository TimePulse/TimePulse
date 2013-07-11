module AuthenticatedSystem

  def logged_in?
    !(current_user.nil?)
  end

  def admin?
    logged_in?
  end

end
