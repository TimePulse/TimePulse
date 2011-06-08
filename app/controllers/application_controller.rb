require 'authenticated_system'

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  include LogicalAuthz::Application

  protect_from_forgery


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
end
