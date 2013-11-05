class WorkUnitFixerController < WorkUnitBaseController
  before_filter :find_work_unit_and_authenticate

  def create

    if (@work_unit.stop_time.present?)
      redirect_to :back
    end
    @work_unit.stop_time = @work_unit.start_time + @work_unit.hours.hours
    @work_unit.save

    respond_to do |format|
      format.html { redirect_to :back }
      format.js
    end
  end

end
