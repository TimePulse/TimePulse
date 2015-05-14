module HoursReportsHelper

  def number_of_weeks_between(start_date, end_date)
    (((end_date.beginning_of_week - start_date.beginning_of_week).to_i) / 7)
  end

  def check_for_missing_weeks(query)
    query_sundays = []
    (0..query.length-1).each do |i|
      query_sundays << query[i][:sunday]
    end
    missing_sundays = @sundays - query_sundays
    (0..missing_sundays.length-1).each do |j|
      query.push( {:sunday => missing_sundays[j], :hours => 0.0} )
    end
    return query.sort_by{ |hash| Date.parse(hash[:sunday]) }
  end

  def hours_reports_data(users,sundays,scope)
    dataset = []
    users.each do |u|
      points = []
      sundays.each do |sun|
        points << [(Date.parse(sun)).strftime('%s').to_i, WorkUnitQuery.new(u,sun,sun,scope).hours]
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