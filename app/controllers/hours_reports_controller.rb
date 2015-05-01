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
  def hours_for(user, start_date, end_date = @end_date.beginning_of_week - 1.second)
    user.work_units.where(:start_time => start_date..end_date)
  end

  def week_endings(start_date, end_date = @end_date.beginning_of_week - 1.day)
    [].tap do |arr|
      sunday = start_date.beginning_of_week - 1.day
      sunday.step(end_date, 7) do |time|
        arr << time.strftime('%b %d %y')
      end
    end
  end

  def default_date_range
    @start_date = Date.strptime((DateTime.now - 5.weeks).strftime('%m/%d/%Y'), '%m/%d/%Y')
    @end_date = Date.strptime((DateTime.now).strftime('%m/%d/%Y'), '%m/%d/%Y')
  end

  def build_report
    @users = User.all.select{ |u| hours_for(u, @start_date.beginning_of_week - 1.second).sum(:hours).to_s.to_f > 0.0 }
    @sundays = week_endings(@start_date)
  end

  def param_date_range
    @start_date = Date.strptime(params[:start_date], '%m/%d/%Y')
    @end_date = Date.strptime(params[:end_date], '%m/%d/%Y')
  end

end
