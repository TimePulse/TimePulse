require 'hhmm_to_decimal'

class ClockTimeController < AuthzController
  include HhmmToDecimal

  before_filter :convert_hours_from_hhmm

  def create
    @project = Project.find(params[:id])
    current_unit = current_user.current_work_unit
    current_unit.clock_out! unless current_unit.nil?
    @work_unit = current_user.work_units.build( :project => @project, :start_time => Time.zone.now )
    @work_unit.save!
    @prior_project = current_user.current_project
    # Reload the associations to grab the current_work_unit
    current_user.current_project = @project
    current_user.save!
    current_user.reload

    respond_to do |format|
      format.html { flash[:success] = "Clocked in."; redirect_to root_path }
      format.js
      format.json do
        render :json => build_json_response
      end
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
      format.json do
        render :json => build_json_response
      end
    end
  end


  def build_json_response
    with_format :html do
      tc = render_to_string(:partial => 'shared/timeclock.html.haml')
      rw = render_to_string(:partial => 'shared/recent_work.html.haml')
      {
        :timeclock => tc,
        :recent_work => rw
      }
    end
  end
end
