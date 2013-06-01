class GithubPullController < ApplicationController
  before_filter :authenticate_admin!

  # POST /projects/1/github_pull
  def create
    
    @github_pull = GithubPull.new(:project_id => params[:project_id])
    
    if @github_pull.save
      flash[:notice] = 'Commits successfully saved.'
    else
      flash[:notice] = 'An error occurred pulling commits'
    end

    respond_to do |format|
      format.json { head :ok }
      format.html { redirect_to(project_path(@github_pull.project)) }
    end

  end

  protected


end
