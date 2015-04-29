class HoursReportsController < ApplicationController
  before_filter :require_admin!

  def index
    start_date = DateTime.now - 5.weeks
    @users = User.all.select{ |u| hours_for(u, start_date).sum(:hours).to_s.to_f > 0.0 }
    @sundays = week_endings(start_date)
  end

  private
  def hours_for(user, start_date, end_date = DateTime.now)
    user.work_units.where(:start_time => start_date..end_date)
  end

  def week_endings(start_date, end_date = DateTime.now.beginning_of_week)
    [].tap do |arr|
      sunday = start_date.beginning_of_week - 1.day
      sunday.step(end_date, 7) do |time|
        arr << time.strftime('%b %d %y')
      end
    end
  end

end
