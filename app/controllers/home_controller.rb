class HomeController < ApplicationController
  before_filter :authenticate_user
  def index
    @user = current_user
    if (@current_project = current_user.current_project )
      @work_units = current_user.work_units_for(@current_project).includes(:project => :client).order("stop_time DESC").paginate(:per_page => 10, :page => params[:page])
    end
  end
end
