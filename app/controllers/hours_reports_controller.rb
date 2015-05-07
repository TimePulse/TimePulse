class HoursReportsController < ApplicationController
  before_filter :require_admin!

  def index
    build_date_range
    build_report
    render :action => :index
  end

  alias :create :index

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

  def build_date_range
    if params[:start_date].present?
      @start_date = Chronic.parse(params[:start_date]).to_date
    else
      @start_date = Date.today - 5.weeks
    end

    if params[:end_date].present?
      @end_date = Chronic.parse(params[:end_date]).to_date
    else
      @end_date = Date.today
    end
  end

  def build_report
    @users = User.all.select{ |u| hours_for(u, @start_date.beginning_of_week - 1.second).sum(:hours).to_s.to_f > 0.0 }
    @sundays = week_endings(@start_date)
  end

end
