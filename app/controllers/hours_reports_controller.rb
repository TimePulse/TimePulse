class HoursReportsController < ApplicationController
  before_filter :require_admin!

  def index
		default_date_range
		build_report
	end

	def create
		param_date_range
		build_report
		render :action => :index
	end

  private
  def hours_for(user, start_date, end_date = @start_date + 5.weeks)
    user.work_units.where(:start_time => start_date..end_date)
  end

  def week_endings(start_date, end_date = (@start_date + 5.weeks).beginning_of_week)
    [].tap do |arr|
      sunday = start_date.beginning_of_week - 1.day
      sunday.step(end_date, 7) do |time|
        arr << time.strftime('%b %d %y')
      end
    end
	end

	def default_date_range
		@start_date = DateTime.now - 5.weeks
	end

	def build_report
		@users = User.all.select{ |u| hours_for(u, @start_date).sum(:hours).to_s.to_f > 0.0 }
		@sundays = week_endings(@start_date)
		p @sundays
	end

	def param_date_range
		@start_date = Date.strptime(params[:start_date], '%m/%d/%Y') - 5.weeks
	end

end
