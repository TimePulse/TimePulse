class CalendarWorkUnitsController < ApplicationController

  before_filter :require_user!
  def index

    @start_time = params[:start]
    @end_time = params[:end]
      if @start_time && @end_time
        @work_units = current_user.work_units.where('start_time >= ?', Time.parse(@start_time).utc).where('stop_time <= ?', Time.parse(@end_time).utc)
      else
        @work_units = current_user.work_units
      end
    respond_to do |format|
      format.html
      format.json { render :json => @work_units, serializer: CalendarEventSerializer}
    end

  end


end