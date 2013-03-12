
class PermissionsController < ApplicationController        

  before_filter :authenticate_admin!

  before_filter :get_permission, :only => [:edit, :update, :destroy]

  def index
    @permissions = Permission.all
  end

  def new
    @permission = Permission.new
  end

  def edit
  end

  def update
    if @permssion.update_attributes(params[:permission])
      flash[:notice] = "Permission updated"
      redirect_to permissions_path
    else
      render :action => :edit
    end
  end

  def destroy
    @permission.try(:destroy)
    redirect_to permissions_path
  end

  def create
    group = Group.find_by_id(params[:group])
    return if group.nil?

    permission_selector = {
      :controller => params[:p_controller], 
      :action => params[:p_action], 
      :subject_id => params[:object],
      :group_id => group.id
    }

    if params["permission"] == "true"
      Permission.create!(permission_selector)
    else
      perms = group.permissions.find(:all, :conditions => permission_selector)        
      perms.each {|perm| perm.destroy}
    end

    respond_to do |format|
      format.js 
      format.html do
        redirect_to :back
      end
    end
  end

  private
  def get_permission
    @permission = Permission.find_by_id(params[:id])
  end
end
