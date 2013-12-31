class CurrentProjectController < HomePageController
  before_filter :require_user!

  def create
    @prior_project = current_user.current_project
    current_user.update_attribute(:current_project_id, params[:id]) if params[:id]
    @current_project = current_user.reload.current_project
    load_related_items

    respond_to do |format|
      format.html { redirect_to :back }
      format.js
    end
  end
end
