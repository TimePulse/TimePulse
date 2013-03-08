require 'authenticated_system'

class ApplicationController < ActionController::Base
  include AuthenticatedSystem

  helper :all # include all helpers, all the time

  helper_method :current_user_session, :current_user
  before_filter :set_current_time


  # see http://stackoverflow.com/questions/339130/how-do-i-render-a-partial-of-a-different-format-in-rails
  def with_format(format, &block)
    old_formats = formats
    begin
      self.formats = [format]
      return block.call
    ensure
      self.formats = old_formats
    end
  end

  def authenticate_user
    if (!current_user)
      store_location
      redirect_to(default_unauthorized_path)
    end
  end

  def authenticate_admin
    if (!current_user.admin?)
      store_location
      redirect_to(default_unauthorized_path)
    end
  end

  def authenticate_owner(user)
    if (!current_user.admin? and current_user != user)
      store_location
      redirect_to(default_unauthorized_path)
    end
  end

  def store_location
    session[:return_to] = request.fullpath;
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def redirect_to_last_unauthorized(message)
    flash[:notice] = message
    redirect_back_or_default(root_path)
  end


  def set_current_time
    @server_time_now = Time.zone.now
  end

end
