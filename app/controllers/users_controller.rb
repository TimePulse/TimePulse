class UsersController < Devise::RegistrationsController

  skip_before_filter :require_no_authentication
  before_filter :authenticate_user!, :only => [:index, :new, :create]
  before_filter :get_user_and_authenticate, :only => [:show, :edit_as_admin, :update_as_admin]
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    @user.groups << Group.find_by_name("Registered Users")
    if @user.save
      flash[:notice] = "Account registered!"
      redirect_to user_path(@user)
    else
      render :action => :new
    end
  end
  
  def index
    @users = User.all
  end

  def show
  end
 
  def edit_as_admin
  end
  
  def update_as_admin
    if @user.update_attributes(params[:user])
      flash[:notice] = "Account updated!"
    end
    render :action => :edit
  end  

  private
  def get_user_and_authenticate
    Rails.logger.debug params.inspect
    @user = User.find(params[:id])
    authenticate_owner!(@user)
  end
end
