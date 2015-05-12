module HoursReportsHelper

  def number_of_weeks_between(start_date, end_date)
    (((end_date.beginning_of_week - start_date.beginning_of_week).to_i) / 7)
  end

  def hours_reports_data(users,sundays,scope)
    dataset = []
    users.each do |u|
      points = []
      sundays.each do |sun|
        points << [(Date.parse(sun)).strftime('%s').to_i, WorkUnitQuery.new(u,sun,scope).hours]
      end
      dataset << points
    end
    return dataset
  end

  def get_names(users)
    names = []
    users.each do |u|
      names << u.name
    end
    return names
  end

  def xaxis_labels(sundays)
    ticks = []
    sundays.each do |sun|
      ticks << [(Date.parse(sun)).strftime('%s').to_i, sun]
    end
    return ticks
  end

end