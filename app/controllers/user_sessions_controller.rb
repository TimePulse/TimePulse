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
      redirect_to_last_unauthorized("Login successful!")
    else
      render :action => :new
    end
  end
 
  def destroy
    current_user_session.destroy
    redirect_to_last_unauthorized("Logout successful!")
  end
end
