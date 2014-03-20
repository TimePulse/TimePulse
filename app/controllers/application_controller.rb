require 'ajax_flash'

class ApplicationController < ActionController::Base
  include AJAXFlash

  protect_from_forgery

  helper :all # include all helpers, all the time

  before_filter :set_current_time

  def require_user!
    if (!current_user)
      store_location
      redirect_to(login_path)
    end
  end

  def require_admin!
    if !current_user or !(current_user.admin?)
      store_location
      redirect_to(login_path)
    end
  end

  def require_owner!(user)
    if (!current_user.admin? and current_user != user)
      store_location
      redirect_to(login_path)
    end
  end

  def store_location
    session[:return_to] = request.fullpath;
  end


  def after_sign_in_path_for(resource)
    return_path = session[:return_to]
    session[:return_to] = nil
    return_path || root_path
  end


  def set_current_time
    @server_time_now = Time.zone.now
  end

end
