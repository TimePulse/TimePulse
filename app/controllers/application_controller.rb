require 'authenticated_system'

class ApplicationController < ActionController::Base
  protect_from_forgery

  include AuthenticatedSystem


  # TODO:  Fix the hell out of this
  def self.needs_authorization;  end
  def self.admin_authorized; end
  def self.owner_authorized(*args); end
  def self.grant_aliases(*args); end
end
