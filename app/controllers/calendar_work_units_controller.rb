class CalendarWorkUnitsController < CalendarController

  before_filter :require_user!
  def index
    user = User.find(params[:user_id])
    @start_time = params[:start]
    @end_time = params[:end]
      # if @start_time && @end_time
      #   @work_units = current_user.work_units.where('start_time >= ?', Time.parse(@start_time).utc).where('stop_time <= ?', Time.parse(@end_time).utc)
      # else
    @work_units = user.work_units.where('start_time >= ?', Time.parse(@start_time).utc).where('stop_time <= ?', Time.parse(@end_time).utc)


    respond_to do |format|
    format.json { render :json => @work_units, each_serializer: CalendarEventSerializer, root: false}
    end

  end


end