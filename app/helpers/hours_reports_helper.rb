module HoursReportsHelper

  def number_of_weeks_between(start_date, end_date)
    (((end_date.beginning_of_week - start_date.beginning_of_week).to_i) / 7)
  end

  def check_for_missing_weeks(query,sundays)
    query_sundays = []
    (0..query.length-1).each do |i|
      query_sundays << query[i][:sunday]
    end
    missing_sundays = sundays - dates_as_strings(query_sundays)
    (0..missing_sundays.length-1).each do |j|
      query.push( {:sunday => Date.parse(missing_sundays[j]), :hours => 0.0} )
    end
    query.sort_by{ |hash| hash[:sunday] }
  end

  def hours_reports_data(users,sundays,kind)
    dataset = []
    users.each do |u|
      query = check_for_missing_weeks(WorkUnitQuery.new(u,sundays.first,sundays.last,kind).hours, sundays)
      points = []
      (0..query.length-1).each do |i|
        points << [query[i][:sunday].strftime('%s').to_i, query[i][:hours]]
      end
      dataset << points
    end
    dataset
  end

  def get_names(users)
    names = []
    users.each do |u|
      names << u.name
    end
    names
  end

  def xaxis_labels(sundays)
    labels = []
    sundays.each do |sun|
      labels << [sun.end_of_day.strftime('%s').to_i, sun.strftime('%b %d %y')]
    end
    labels
  end

  def dates_as_strings(dates)
    dates_as_strings = []
    dates.each do |d|
      dates_as_strings << d.strftime('%b %d %y')
    end
    dates_as_strings
  end

end