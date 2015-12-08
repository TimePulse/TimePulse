require 'hhmm_to_decimal'

class ClockTimeController < WorkUnitBaseController
  before_filter :require_user!

  include HhmmToDecimal

  before_filter :convert_hours_from_hhmm

  def create
    @work_unit = current_user.current_work_unit
    clock_out_current_work_unit
    @project = Project.find(params[:id])
    @work_unit = WorkUnit.new(:start_time => Time.zone.now )
    @work_unit.project = @project
    @work_unit.user = current_user
    @work_unit.save
    @prior_project = current_user.current_project

    # Reload the associations to grab the current_work_unit
    current_user.update_attribute(:current_project, @project)

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
    if params[:work_unit]
      if (params[:work_unit][:stop_time])
        parse_date_params
      end
      @work_unit.update(clock_params)
    end
    clock_out_current_work_unit
    expire_fragment("work_unit_narrow_#{@work_unit.id}")


    current_user.reload
    respond_to do |format|
      format.html { flash[:success] = "Clocked out."; redirect_to root_path }
      format.js
    end
  end

  def clock_out_current_work_unit
    if @work_unit
      @work_unit.clock_out!
    end
  end

  private

  def clock_params
    params.
    require(:work_unit).
    permit(:notes,
      :start_time,
      :stop_time,
      :hours,
      :billable,
      :project_id)
  end

end
