class ProjectsController < ApplicationController
  before_filter :require_admin!

  # GET /projects
  def index
    @root_project = Project.root
  end

  # GET /projects/1
  def show
    @project = Project.find(params[:id])
    @repos = @project.repositories
    @active_users = User.active
  end

  # GET /projects/new
  def new
    @project_form = ProjectForm.new
    @project_form.set_defaults
    @project_form.form_options = {url: projects_path, method: :post}
  end

  # GET /projects/1/edit
  def edit
    @project_form = ProjectForm.find(params[:id])
    @project_form.append_new_rate if @project_form.project.parent == Project.root
    @project_form.form_options = {url: project_path(params[:id]), method: :put}
  end

  # POST /projects
  def create
    @project_form = ProjectForm.new(project_form_params)
    if @project_form.save
      flash[:notice] = 'Project was successfully created.'
      expire_fragment "picker_node_#{@project_form.project.id}"
      expire_fragment "project_picker"
      redirect_to(@project_form.project)
    else
      @project_form.append_new_rate
      @project_form.form_options = {url: projects_path, method: :post}
      render :action => "new"
    end
  end

  # PUT /projects/1
  def update
    @project_form = ProjectForm.find(params[:id])
    @project_form.attributes = project_form_params
    if @project_form.save
      expire_fragment "picker_node_#{@project_form.project.id}"
      expire_fragment "project_picker"
      flash[:notice] = 'Project was successfully updated.'
      redirect_to :action => "index"
    else
      @project_form.append_new_rate
      @project_form.form_options = {url: project_path(params[:id]), method: :put}
      render :action => "edit"
    end
  rescue ActiveRecord::ActiveRecordError
    flash[:error] = "Illegal self referential or circular parent assignment"
    redirect_to(@project_form.project)
  end
    
    

  # DELETE /projects/1
  def destroy
    @project = Project.find(params[:id])
    @id = params[:id]
    @repos = @project.repositories
    @repos.each { |repo| repo.destroy }
    @project.destroy

    expire_fragment "project_picker"

    respond_to do |format|
      format.html { redirect_to projects_path }
      format.js
    end
  end

  private

  def project_form_params
    params.
    require(:project_form).
    permit(:name,
           :account,
           :description,
           :clockable,
           :billable,
           :flat_rate,
           :archived,
           :pivotal_id,
           :client_id,
           :parent_id,
           :rates_attributes => [:id, :name, :amount, :_destroy],
           :repositories_attributes => [:id, :url, :_destroy]
    )
  end

end
