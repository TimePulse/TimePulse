require 'bcrypt'
class ActivitiesController < ApplicationController
  include WorkUnitsHelper
  before_action :restrict_access, only: [:create]

  def create
    @user = User.where(:login => request.headers["login"]).first
    @current_work_unit = @user.work_units.where(:stop_time => nil).last
    @activity = Activity.new(activity_params)
    p @current_work_unit.id
    #check to see if the user making the request has an open work unit
    if @current_work_unit
      p "there is an open work unit"
      if @current_work_unit.project_id == @activity.project_id
        p "project_id is equal"
        @activity.work_unit_id = @current_work_unit.id
        p @activity.work_unit_id
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
    @user = User.where(:login => request.headers["login"]).first
    unless @user = User.where(:login => request.headers["login"]).first
      render json: "authorization failed no user" , status: 403
    end
    utoken = request.headers["Authorization"]
    if BCrypt::Password.new(@user.encrypted_token) == utoken
      return true
    else
      render json: "authorization failed wrong token", status: 403
    end
  end
end
