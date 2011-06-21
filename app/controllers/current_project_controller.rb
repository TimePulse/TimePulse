class CurrentProjectController < ApplicationController
  def create
    @prior_project = current_user.current_project
    current_user.update_attribute(:current_project_id, params[:id]) if params[:id]
    @current_project = current_user.reload.current_project
    respond_to do |format|
      format.html { redirect_to :back }
      format.js
    end
  end
end
