class WorkUnitQuery

  def initialize(user, start_date, end_date, kind)
    @user = user
    @kind = kind

    start_date = DateTime.parse(start_date) if start_date.is_a?(String)
    end_date = DateTime.parse(end_date) if end_date.is_a?(String)
    if start_date.cwday == 7
      @starting_monday = start_date.beginning_of_day + 1.day - 1.week
    else
      @starting_monday = start_date.beginning_of_week - 1.week
    end
    if end_date.cwday == 7
      @ending_sunday = end_date.end_of_week
    else
      @ending_sunday = end_date.end_of_week
    end
  end

  def hours
    scope = @user.work_units
                 .where(:start_time => @starting_monday..@ending_sunday)
                 .group("date_part('week', work_units.start_time)")
                 .select('SUM(work_units.hours) as hours, MIN(work_units.start_time) as min_start_time')

    if @kind == 'billable' || @kind == 'unbillable'
      scope = scope.send(@kind.to_sym)
    end

    result = scope.map { |res| {:sunday => res.min_start_time.end_of_week,
                                :hours  => res.hours.to_f } }
    return result.sort_by{ |hash| hash[:sunday] }
  end

end
