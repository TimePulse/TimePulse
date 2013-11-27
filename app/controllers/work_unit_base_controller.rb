class WorkUnitBaseController < ApplicationController
  def find_work_unit_and_authenticate
    @work_unit = WorkUnit.find(params[:id])
    raise ArgumentError, 'Invalid work_unit id provided' unless @work_unit
    require_owner!(@work_unit.user)
  end

  def parse_date_params
    if wu_p = params[:work_unit]
      zone = Time.zone
      if wu_p.has_key?(:time_zone)
        zone = wu_p[:time_zone].to_i
      end
      Time.use_zone(zone) do
        wu_p[:start_time] = parse_time(wu_p[:start_time]) if wu_p[:start_time]
        wu_p[:stop_time] = parse_time(wu_p[:stop_time]) if wu_p[:stop_time]
      end
    end
  end

  def parse_time(string)
    time_options = { :now => Time.zone.now, :context => :past }
    Chronic.time_class = Time.zone
    Chronic.parse(string, time_options)
  end

end