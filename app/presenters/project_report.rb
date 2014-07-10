class ProjectReport
	def initialize(project)
		@project = project
		@user_hours = user_hours
		@users = users
	end

	attr_reader :project, :user_hours, :users

	def users(scope = self.work_units)
		scope.to_a.map{|pwu| pwu.user}.uniq
	end

	def user_hours		
		user_hours = {}
    self.work_units.each do |wu|
      user_hours[wu.user.id] ||= 0.0
      user_hours[wu.user.id] += wu.hours
    end
    user_hours
	end

	def build_user_report
		@rows = Hash.new 

		@users.each do |user|
			if rates = user.rates.find_by(:project_id => @project.id)
				rate = rates.amount
			else 
				#TODO: handle unset rate, for now defaulting to $0.00
				rate = 0
			end

			fields = Hash[:name => user.name, :hours => @user_hours[user.id], :rate => rate, :cost => (@user_hours[user.id] * rate)]
			@rows[user.id] = fields
		end

		@rows
	end

	def work_units
		@work_units = WorkUnit.for_project(@project).completed.billable.uninvoiced.flatten.uniq
	end
end