class WorkUnitQuery

  def initialize(user, start_date, scope)
    @user = user
    if start_date.is_a?(String)
      @starting_sunday = DateTime.parse(start_date).end_of_week - 1.week
      @ending_sunday = DateTime.parse(start_date).end_of_week
    else
      @starting_sunday = start_date.end_of_week - 1.week
      @ending_sunday = start_date.end_of_week
    end
    @scope = scope
  end

  def hours
    if @scope == 'total'
      @user.work_units.where(:start_time => @starting_sunday..@ending_sunday)
                      .sum(:hours)
                      .to_s.to_f
    elsif @scope == 'billable' || @scope == 'unbillable'
      @user.work_units.where(:start_time => @starting_sunday..@ending_sunday)
                      .send(@scope.to_sym)
                      .sum(:hours)
                      .to_s.to_f
    end
  end

end