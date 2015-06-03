require 'bcrypt'
class ActivitiesController < ApplicationController
  # include WorkUnitsHelper
  before_action :restrict_access, only: [:create]
  before_filter :authenticate_user!

  def create
    @user = current_user
    @current_work_unit = @user.current_work_unit
    @activity = Activity.new(activity_params)
    #check to see if the user making the request has an open work unit
    if @current_work_unit
      if @current_work_unit.project_id == @activity.project_id
        @activity.work_unit_id = @current_work_unit.id
      end
    end
    if @activity.save
      render json: @activity, status: 201
    else
      render json: @activity.errors, status: 422
    end
  end

  private

  def activity_params
    params.require(:activity).permit(:description, :work_unit_id, :project_id, :source, :time, :action, :user_id, properties: [:story_id])
  end

  def restrict_access
    user_email = request.headers["login"].presence
    user       = user_email && User.find_by(:login => user_email)
    if user
      stored_token = user.encrypted_token
      stored_password = BCrypt::Password.new(stored_token)
      presented_token = BCrypt::Engine.hash_secret(request.headers["Authorization"], stored_password.salt)

      if Devise::secure_compare(stored_token, presented_token)
        sign_in user, store: false
      end
    end
  end
end
