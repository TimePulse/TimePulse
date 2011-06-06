class UserSessionsController < AuthzController
  policy :new do
    deny authenticated
    allow always
  end
  grant_aliases :new => :create

  policy :destroy do
    allow authenticated
  end

  def new
    @user_session = UserSession.new
  end
 
  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      flash[:notice] = "Login successful!"
      redirect_back_or_default root_url
    else
      render :action => :new
    end
  end
 
  def destroy
    current_user_session.destroy
    flash[:notice] = "Logout successful!"
    redirect_back_or_default new_user_session_url
  end
end
