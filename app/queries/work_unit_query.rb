class WorkUnitQuery

	def initialize(user, chosen_day, num_weeks_ago, scope)
		@user = user
		@num_weeks_ago = num_weeks_ago
		@scope = scope
		@chosen_day = chosen_day
	end

	def hours
		if @scope == 'total'
			@user.work_units.where(:start_time => @chosen_day.beginning_of_week - 1.second - ((@num_weeks_ago * 7) - 1).days..@chosen_day.beginning_of_week - 1.second - ((@num_weeks_ago - 1) * 7).days).sum(:hours).to_s.to_f
		elsif @scope == 'billable' || @scope == 'unbillable'
			@user.work_units.where(:start_time => @chosen_day.beginning_of_week - 1.second - ((@num_weeks_ago * 7) - 1).days..@chosen_day.beginning_of_week - 1.second - ((@num_weeks_ago - 1) * 7).days).send(@scope.to_sym).sum(:hours).to_s.to_f
		end
	end

end