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
    redirect_to(default_unauthorized_path) unless current_user
  end

  def authenticate_admin
    redirect_to(default_unauthorized_path) unless current_user.admin?
  end

  def authenticate_owner(user)
    redirect_to(default_unauthorized_path) unless (current_user.admin? or current_user == user)
  end

  def store_location
    session[:return_to] = request.request_uri
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def set_current_time
    @server_time_now = Time.zone.now
  end

end
