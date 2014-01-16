class ProjectReportsController < ApplicationController
  before_filter :require_admin!
  def show
     @project = Project.find(params[:id])
     @project_report = ProjectReport.new(@project)
  end
  
  def index
    @project = Project.new()
    @projects = Project.find(:all)
    if params[:client_id]
      @invoice.client = @client
      @work_units = WorkUnit.for_project(@project).completed.billable.uninvoiced.flatten.uniq
    end
  end
end
