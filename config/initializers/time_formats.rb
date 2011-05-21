my_formats = {
  :short_date => '%-m/%-d/%Y',              # 3/2/2010
  :time => "%-I:%M %p ",                    # 2:06 pm
  :month_year => "%b %Y",                   # Mar 2010
  :month_day_year => "%d, %B, %Y",          # March 2, 2010
  :short_datetime => '%m/%d/%Y %T',         # 3/2/2010 02:06:00    ( or 3/2/2010 02:06:00 for morning)
  :datetime => "%B %d, %Y %l:%M %p",        # March 2, 2010 2:06 pm
  :date => "%B %-d, %Y",                    # March 2, 2010,
  :weekday_month_day_year => "%A, %B %-d, %Y",  # Tuesday, March 2, 2010
  :year_month_day => "%Y %b %d"
}
Time::DATE_FORMATS.merge!(my_formats)
Date::DATE_FORMATS.merge!(my_formats)