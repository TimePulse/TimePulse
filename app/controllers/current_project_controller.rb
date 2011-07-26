class CurrentProjectController < ApplicationController
  def create
    @prior_project = current_user.current_project
    current_user.update_attribute(:current_project_id, params[:id]) if params[:id]
    @current_project = current_user.reload.current_project
    @work_units = current_user.work_units_for(@current_project).order("stop_time DESC").paginate(:per_page => 10, :page => params[:page])

    respond_to do |format|
      format.html { redirect_to :back }
      format.js
    end
  end
end
