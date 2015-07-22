class GithubPullController < ApplicationController
  before_filter :require_admin!

  # TODO
  # Test github_pulls on projects with multiple and zero repositories
  
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
      format.html { redirect_to(project_path(@github_pull.projects.first)) }
    end
  end
end
