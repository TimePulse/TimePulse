class AnnotationsController < ApplicationController
  before_filter :require_user!

  #POST
  def create

    @current_work_unit = current_user.current_work_unit
    @activity = Activity.new(activity_params)
    @activity.time = Time.now.utc
    #check to see if the user making the request has an open work unit
    #
    if @current_work_unit.present?
      if @current_work_unit.project == @activity.project
        @activity.work_unit = @current_work_unit
      end
    end

    respond_to do |format|
      if @activity.save
        flash[:notice] = 'Annotation was successfully created.'
        format.js
      end
    end
  end

  private

  def activity_params
    params.require(:activities).permit(:description, :work_unit_id, :project_id, :source, :time, :action, :user_id, properties: [:story_id])
  end
end
