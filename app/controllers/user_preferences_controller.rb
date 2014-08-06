class UserPreferencesController < ApplicationController

  def edit
    @user = current_user
    @user_preferences = @user.user_preferences
  end

  def update
    @user_preferences = current_user.user_preferences
    @user_preferences.update(user_preferences_params)
    flash[:notice] = "Preferences updated!"
    redirect_to edit_user_path(current_user)
  end

  private

  def user_preferences_params
    params.
    require(:user_preferences).
    permit(:recent_projects_count)
  end

end
