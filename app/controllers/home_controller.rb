class HomeController < ApplicationController
  before_filter :require_user!
  def index
    @user = current_user
    if (@current_project = current_user.current_project )
      @work_units = current_user.completed_work_units_for(@current_project).includes(:project => :client).order("stop_time DESC").paginate(:per_page => 10, :page => params[:work_units_page])
      @commits = current_user.git_commits_for(@current_project).includes(:project => :client).order("time DESC").paginate(:per_page => 10, :page => params[:commits_page])
      @pivotal_updates = current_user.pivotal_updates_for(@current_project).includes(:project => :client).order("time DESC").paginate(:per_page => 10, :page => params[:pivotal_updates_page])
    end
  end
end
