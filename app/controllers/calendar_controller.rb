class CalendarController < ApplicationController
   before_filter :require_user!
  def index
    if current_user.admin?
      @users = User.active
    else
      @users = [current_user]
    end
    @colorsArray = [0099FF, 66FF66, CCFF33, FF6600, FF3399, CC66FF, 666699, 800000, 339933, FFFF00, 003366]

    respond_to do |format|
      format.html
    end

  end

end

