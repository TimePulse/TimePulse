class ProjectsController < ApplicationController
  before_filter :authenticate_admin!
  # GET /projects

  def index
    @root_project = Project.root
  end

  # GET /projects/1
  def show
    @project = Project.find(params[:id])
  end

  # GET /projects/new
  def new
    @project = Project.new
  end

  # GET /projects/1/edit
  def edit
    @project = Project.find(params[:id])
  end

  # POST /projects
  def create
    @project = Project.new(params[:project])

      if @project.save
        flash[:notice] = 'Project was successfully created.'
        expire_fragment "picker_node_#{@project.id}"
        expire_fragment "project_picker"
        redirect_to(@project)
      else
        render :action => "new"
      end
  end

  # PUT /projects/1
  def update
    @project = Project.find(params[:id])
    if @project.update_attributes(params[:project])
      expire_fragment "picker_node_#{@project.id}"
      expire_fragment "project_picker"
      flash[:notice] = 'Project was successfully updated.'
      redirect_to(@project)
    else
      render :action => "edit"
    end
  end

  # DELETE /projects/1
  def destroy
    @project = Project.find(params[:id])
    @id = params[:id]
    @project.destroy

    respond_to do |format|
      format.html { redirect_to projects_path }
      format.js
    end
  end

end
