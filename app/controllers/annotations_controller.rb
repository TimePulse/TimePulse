class AnnotationsController < ApplicationController
  before_filter :require_user!

  #POST
  def create
    if params[:activities][:work_unit_id].blank?
      @work_unit = current_user.current_work_unit
    else
      @work_unit = WorkUnit.find(params[:activities][:work_unit_id])
    end

    @activity = Activity.new(activity_params)

    #check to see if the user making the request has an open work unit
    #
    if @work_unit.present?
      if @work_unit.project == @activity.project
        @activity.work_unit = @work_unit
      end

      if @activity.time.blank?
        if @work_unit.in_progress?
          @activity.time = Time.now.utc
        else
          @activity.time = @work_unit.stop_time
        end
     end
     expire_fragment("work_unit_narrow_#{@work_unit.id}")
    end

    respond_to do |format|
      if @activity.save
        flash[:notice] = 'Annotation was successfully created.'
        format.js
      end
    end
  end

  #DELETE
  def destroy
    @annotation = Activity.find(params[:id])
    if @annotation.work_unit
      @work_unit = @annotation.work_unit
    end
    @annotation.destroy
    respond_to do |format|
      format.js
    end
  end

  private

  def activity_params
    params.require(:activities).permit(:description, :work_unit_id, :project_id, :source, :time, :action, :user_id, properties: [:story_id])
  end
end
