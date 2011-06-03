require 'authenticated_system'

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  include LogicalAuthz::Application

  protect_from_forgery
end
