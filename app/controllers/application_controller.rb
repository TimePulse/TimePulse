require 'authenticated_system'

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  include LogicalAuthz::Application

  helper :all # include all helpers, all the time

  protect_from_forgery
  needs_authorization
  admin_authorized

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
