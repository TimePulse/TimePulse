require 'bcrypt'
class ActivitiesController < ApplicationController
  # include WorkUnitsHelper
  before_action :restrict_access, only: [:create]
  before_filter :authenticate_user!
  skip_before_filter :verify_authenticity_token

  # #GET
  # def index
  #   @activity = current_user.reload.activities.last(10)
  # end

  #POST /activities
  def create
    @current_work_unit = current_user.current_work_unit
    @activity = Activity.new(activity_params)
    #check to see if the user making the request has an open work unit
    #
    if @current_work_unit.present?
      if @current_work_unit.project == @activity.project
        @activity.work_unit = @current_work_unit
      end
    end
    if @activity.save
      flash[:notice] = 'Annotation was successfully created.'
      format.html { redirect_to(@activity) }
      format.js {
        @activity = Activity.new
        @activities = current_user.completed_annotations_for(current_user.current_project).order(stop_time: :desc).paginate(:per_page => 10, :page => nil)
      }

      # p "***********************"
      # p @activity.errors
      format.json { render json: @activity, status: 201 }
    else
      format.html { render :action => "annotate" }
      format.json { render json: @activity.errors, status: 422 }
    end
  end

  private

  def activity_params
    params.require(:activities).permit(:description, :work_unit_id, :project_id, :source, :time, :action, :user_id, properties: [:story_id])
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