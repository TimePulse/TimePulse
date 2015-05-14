class WorkUnitQuery

  def initialize(user, start_date, end_date, kind)
    @user = user

    if start_date.is_a?(String) && end_date.is_a?(String)
      if DateTime.parse(start_date).strftime('%A') == 'Sunday'
        @starting_monday = (DateTime.parse(start_date).beginning_of_day + 1.day) - 1.week
      elsif DateTime.parse(start_date).strftime('%A') != 'Sunday'
        @starting_monday = (DateTime.parse(start_date).beginning_of_week) - 1.week
      end
      if DateTime.parse(end_date).strftime('%A') == 'Sunday'
        @ending_sunday = DateTime.parse(end_date).end_of_week
      elsif DateTime.parse(end_date).strftime('%A') != 'Sunday'
        # @ending_sunday = DateTime.parse(end_date).beginning_of_week - 1.second
        @ending_sunday = DateTime.parse(end_date).end_of_week
      end
    elsif !start_date.is_a?(String) && !end_date.is_a?(String)
      if start_date.strftime('%A') == 'Sunday'
        @starting_monday = start_date.beginning_of_day + 1.day - 1.week
      elsif start_date.strftime('%A') != 'Sunday'
        @starting_monday = start_date.beginning_of_week - 1.week
      end
      if end_date.strftime('%A') == 'Sunday'
        @ending_sunday = end_date.end_of_week
      elsif end_date.strftime('%A') != 'Sunday'
        # @ending_sunday = end_date.beginning_of_week - 1.second
        @ending_sunday = end_date.end_of_week
      end
    end

    @kind = kind
  end

  def hours
    scope = @user.work_units
                .where(:start_time => @starting_monday..@ending_sunday)
                .group("date_part('week', work_units.start_time)")
                .select('SUM(work_units.hours) as hours, MIN(work_units.start_time) as min_start_time')

    if @kind == 'billable' || @kind == 'unbillable'
      scope = scope.send(@kind.to_sym)
    end

    result = scope.map { |res| {:sunday => (res.min_start_time.end_of_week).strftime('%b %d %y'),
                                :hours => res.hours.to_f } }
    return result.sort_by{ |hash| Date.parse(hash[:sunday]) }
  end

end
