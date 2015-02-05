namespace :reports do
  task :hours_by_week => :environment do
    dates = week_beginnings(DateTime.now.beginning_of_year)
    first = dates.min
    users = User.all.select{|u| hours_for(u, first) > 0.0 }
    results = {}
    results['weeks beginning'] = dates
    users.each do |user|
      results[user.login] = dates.map do |dt|
        hours_for(user, dt, dt.end_of_week).to_s
      end
    end
    #require 'pp'
    #pp results
    require 'csv'
    out = CSV.generate do |csv|
      results.each do |name, vals|
        csv << [ name ] + vals
      end
    end
    puts out
  end

  def week_beginnings(start_date, end_date = DateTime.now)
    [].tap do |arr|
      start_date.beginning_of_week.step(end_date, 7) do |time|
        arr << time
      end
    end
  end

  def hours_for(user, start_date, end_date = DateTime.now)
    user.work_units.billable.completed.where(:start_time => start_date..end_date).sum(:hours)
  end
end
