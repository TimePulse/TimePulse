class HoursReportsController < ApplicationController
  include HoursReportsHelper
  before_filter :require_admin!

  def index
    build_date_range
    build_report
    @users_with_hours = users_with_hours(@users)
    render :action => :index
  end

  alias :create :index

  private
  def users_with_hours(users)
    users_with_hours = {}
    users.each do |u|
      users_with_hours[u.login.to_sym] = {
        :billable => check_for_missing_weeks(WorkUnitQuery.new(u,@sundays[0],@sundays[@sundays.length-1],'billable').hours),
        :unbillable => check_for_missing_weeks(WorkUnitQuery.new(u,@sundays[0],@sundays[@sundays.length-1],'unbillable').hours),
        :total => check_for_missing_weeks(WorkUnitQuery.new(u,@sundays[0],@sundays[@sundays.length-1],'total').hours)
      }
    end
    return users_with_hours
  end

  def hours_for(user, start_date, end_date = @end_date.end_of_week - 1.week)
    user.work_units.where(:start_time => start_date..end_date).sum(:hours).to_s.to_f
  end

  def week_endings(start_date, end_date = @end_date.end_of_week - 1.week)
    [].tap do |arr|
      sunday = (start_date.beginning_of_week - 1.day) + 1.week
      sunday.step(end_date, 7) do |time|
        arr << time.strftime('%b %d %y')
      end
    end
  end

  def build_date_range
    if params[:start_date].present?
      @start_date = Chronic.parse(params[:start_date]).to_date
    else
      @start_date = Date.today - 6.weeks
    end

    if params[:end_date].present?
      @end_date = Chronic.parse(params[:end_date]).to_date
    else
      @end_date = Date.today
    end
  end

  def build_report
    @users = User.all.select{ |u| hours_for(u, @start_date.end_of_week - 1.week) > 0.0 }
    @sundays = week_endings(@start_date)
  end

end
