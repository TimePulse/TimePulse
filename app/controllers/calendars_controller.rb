class CalendarsController < ApplicationController
   before_filter :require_user!
  def index
    if current_user.admin?
      @users = User.active.order("name ASC")
    else
      @users = [current_user]
    end

    respond_to do |format|
      format.html
    end

  end

end

