module HoursReportsHelper

  def number_of_weeks_between(start_date, end_date)
    (((end_date.beginning_of_week - start_date.beginning_of_week).to_i) / 7)
  end

  def hours_reports_data(users,sundays,scope)
    data = []
    users.each do |u|
      sundays.each do |sun|
        data << [sun, WorkUnitQuery(u,sun,scope).hours]
      end
    end
  end

end