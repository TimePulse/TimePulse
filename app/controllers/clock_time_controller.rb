require 'hhmm_to_decimal'

class ClockTimeController < ApplicationController
  before_filter :authenticate_user!

  include HhmmToDecimal

  before_filter :convert_hours_from_hhmm

  def create
    @project = Project.find(params[:id])
    current_unit = current_user.current_work_unit
    current_unit.clock_out! unless current_unit.nil?
    @work_unit = current_user.work_units.build( :project => @project, :start_time => Time.zone.now )
    @work_unit.save!
    expire_fragment("work_unit_narrow_#{@work_unit.id}")
    expire_fragment("work_unit_one_line_#{@work_unit.id}")
    @prior_project = current_user.current_project
    # Reload the associations to grab the current_work_unit
    current_user.current_project = @project
    current_user.save!
    current_user.reload

    respond_to do |format|
      format.html { flash[:success] = "Clocked in."; redirect_to root_path }
      format.js
    end
  rescue ActiveRecord::RecordNotFound
    flash[:error] = "Could not find the project you specified, or you are not authorized to use it."
    redirect_back_or_default(root_url)
  end

  def destroy
    @work_unit = current_user.current_work_unit
    @work_unit.update_attributes(params[:work_unit]) if params[:work_unit]
    @work_unit.clock_out!
    current_user.reload
    respond_to do |format|
      format.html { flash[:success] = "Clocked out."; redirect_to root_path }
      format.js
    end
  end

end
