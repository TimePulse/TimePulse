class ProjectReportsController < ApplicationController
  before_filter :require_admin!

  def new
    @projects = Project.find(:all)
    if params[:project_id]
      find_project
      @work_units = WorkUnit.for_project(@project).completed.billable.uninvoiced.flatten.uniq
    end
  end
  
  private
  
  def find_project
    @project = Project.find_by_id(params[:project_id])
    unless @project
      flash[:error] = "Could not find the specified project"
      redirect_to :back
    end
  end
  
end
