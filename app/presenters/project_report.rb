class ProjectReport
	def initialize(project)
		@project = project
	end

	attr_reader :project, :rates

  def users(scope = self.work_units)
    scope.to_a.map{|pwu| pwu.user}.uniq
  end

	def rates
		@project.base_rates
	end

	def by_hours_hash(&block)
		by_hours = {}
		self.work_units.each do |wu|
			model = yield(wu)
			if model
				key = model.id
				by_hours[key] ||= 0
				by_hours[key] += wu.hours
			end
		end
		by_hours
	end

	def user_hours
		by_hours_hash { |wu| wu.user }
	end

	def rate_hours
		by_hours_hash { |wu| wu.rate }
	end

	def work_units
		@work_units = WorkUnit.for_project(@project).completed.billable.uninvoiced.flatten.uniq
	end

	def build_user_report
		user_hours = self.user_hours

		rows = Hash.new

		self.users.each do |user|
			rate = user.rate_for(@project)

			fields = Hash[:name => user.name, :hours => user_hours[user.id], :rate => rate.amount, :cost => (user_hours[user.id] * rate.amount)]
			rows[user.id] = fields
		end

		rows
	end

	def build_rate_report
		rate_hours = self.rate_hours

		rows = Hash.new

		self.rates.each do |rate|
			if rate_hours[rate.id]
				total_cost = rate_hours[rate.id] * rate.amount
			else
				total_cost = 0
				# Places a zero in the table instead of leaving it blank
				rate_hours[rate.id] = 0
			end

			fields = Hash[:name => rate.name, :hours => rate_hours[rate.id], :rate => rate.amount, :cost => total_cost]
			rows[rate.id] = fields
		end

		rows
	end

end