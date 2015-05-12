class WorkUnitQuery

  def initialize(user, end_of_week, num_weeks_ago, scope)
    @user = user
		@end_of_week = end_of_week.beginning_of_week - 1.second
    @num_weeks_ago = num_weeks_ago
    @scope = scope
  end

  def hours
    if @scope == 'total'
      @user.work_units.where(:start_time => @end_of_week - ((@num_weeks_ago * 7)).days..@end_of_week - ((@num_weeks_ago - 1) * 7).days).sum(:hours).to_s.to_f
    elsif @scope == 'billable' || @scope == 'unbillable'
      @user.work_units.where(:start_time => @end_of_week - ((@num_weeks_ago * 7)).days..@end_of_week - ((@num_weeks_ago - 1) * 7).days).send(@scope.to_sym).sum(:hours).to_s.to_f
    end
  end

end