module HoursReportsHelper

  def number_of_weeks_between(start_date, end_date)
    (((end_date.beginning_of_week - start_date.beginning_of_week).to_i) / 7)
  end

  def dates_to_strings(dates)
    dates_stringified = []
    dates.each { |d| dates_stringified << d.strftime('%b %d %y') }
    dates_stringified
  end

  def check_for_missing_weeks(query,sundays)
    query_sundays = []
    (0..query.length-1).each do |i|
      query_sundays << query[i][:sunday].to_datetime
    end
    missing_sundays = dates_to_strings(sundays) - dates_to_strings(query_sundays.sort)
    (0..missing_sundays.length-1).each do |j|
      query.push( {:sunday => DateTime.parse(missing_sundays[j]).end_of_day, :hours => 0.0} )
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

end