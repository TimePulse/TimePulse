class UserPreferencesController < ApplicationController

  def edit
    @user = current_user
    @user_preferences = @user.user_preferences
  end

  def update
    @user = current_user
    @user_preferences = @user.user_preferences
    @user_preferences.update_attribute( :recent_projects_count, params[:user_preferences][:recent_projects_count] )
    flash[:notice] = "Preferences updated!"
    render :action => :edit
  end

end