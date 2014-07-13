class ProjectReportsController < ApplicationController
  before_filter :require_admin!

  def new
    @projects = Project.all
    if params[:project_id]
      find_project
      @project_report = ProjectReport.new(@project)
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
