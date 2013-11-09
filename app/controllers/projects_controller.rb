class ProjectsController < ApplicationController
  before_filter :require_admin!

  # GET /projects
  def index
    @root_project = Project.root
  end

  # GET /projects/1
  def show
    @project = Project.find(params[:id])

    @active_users = User.active
  end

  # GET /projects/new
  def new
    @project = Project.new
    @project.rates.build
  end

  # GET /projects/1/edit
  def edit
    @project = Project.find(params[:id])
    @project.rates.build if @project.parent == Project.root
  end

  # POST /projects
  def create
    @project = Project.new
    @project.attributes = params[:project]
    add_client
    add_parent
    if @project.save
      flash[:notice] = 'Project was successfully created.'
      expire_fragment "picker_node_#{@project.id}"
      expire_fragment "project_picker"
      redirect_to(@project)
    else
      @project.rates.build
      render :action => "new"
    end
  end

  # PUT /projects/1
  def update
    @project = Project.find(params[:id])
    add_client
    add_parent
    if @project.update_attributes(params[:project])
      expire_fragment "picker_node_#{@project.id}"
      expire_fragment "project_picker"
      flash[:notice] = 'Project was successfully updated.'
      redirect_to(@project)
    else
      @project.rates.build
      render :action => "edit"
    end
  rescue ActiveRecord::ActiveRecordError
    flash[:error] = "Illegal self referential or circular parent assignment"
    redirect_to(@project)
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

  protected
  def add_client
    if params[:project].has_key?(:client_id)
      @project.client_id = params[:project][:client_id]
    end
  end

  def add_parent
    if params[:project].has_key?(:parent_id)
      @project.parent_id = params[:project][:parent_id]
    end
  end
end
