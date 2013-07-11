class PivotalPullController < ApplicationController
  before_filter :require_admin!

  # POST /projects/1/github_pull
  def create

    @pivotal_pull = PivotalPull.new(:project_id => params[:project_id])

    if @pivotal_pull.save
      flash[:notice] = 'Activity successfully saved.'
    else
      flash[:notice] = 'An error occurred pulling commits'
    end

    respond_to do |format|
      format.json { head :ok }
      format.html { redirect_to(project_path(@pivotal_pull.project)) }
    end

  end

  protected


end
