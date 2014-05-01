class UserPreferencesController < ApplicationController

  def edit
    @user_preferences = UserPreferences
  end

  def update
    @user.update_attribute( :recent_projects_count, params[:user][:user_preferences] )
    render :action => :edit
  end
end