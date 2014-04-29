class UsersPreferencesController < Devise::RegistrationsController

  def edit

  end

  def update
    if current_user.admin?
      if params[:user][:admin]
        @user.update_attribute( :admin, params[:user][:admin] )
      end
      if params[:user][:inactive]
        @user.update_attribute( :inactive, params[:user][:inactive] )
      end
    end
    @user.update_attributes(params[:user])
  end
  render :action => :edit
end

end
