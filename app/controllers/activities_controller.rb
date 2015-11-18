require 'bcrypt'
class ActivitiesController < ApplicationController
  # include WorkUnitsHelper
  before_action :restrict_access, only: [:create]
  before_filter :authenticate_user!
  # skip_before_filter :verify_authenticity_token

  #POST /activities
  def create
    @current_work_unit = current_user.current_work_unit
    @activity = current_user.activities.new(activity_params)
    #check to see if the user making the request has an open work unit

    if @current_work_unit.present?
      if @current_work_unit.project == @activity.project
        @activity.work_unit = @current_work_unit
      end
    end
    if @activity.save
      flash[:notice] = 'Annotation was successfully created.'
      respond_to do |format|
        format.html { redirect_to(@activity) }
        format.json { render json: @activity, status: 201 }
      end
    else
      respond_to do |format|
        format.html { render :action => "annotate" }
        format.json { render json: @activity.errors, status: 422 }
      end
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
