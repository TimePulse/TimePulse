module HoursReportsHelper

  def number_of_weeks_between(start_date, end_date)
    (((end_date.beginning_of_week - start_date.beginning_of_week).to_i) / 7)
  end

  def hours_reports_data(users)
    data = []
    users.each do |u|
      data << []
    end
  end

end