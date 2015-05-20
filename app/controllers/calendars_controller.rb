class CalendarsController < ApplicationController
   before_filter :require_user!
  def index
    if current_user.admin?
      @users = User.active.order("name ASC")
    else
      @users = [current_user]
    end

    @calendarArgs = @users.each_with_index.map do |user, index|
                "{
                  url: '/calendar_work_units.json?user_id=#{user.id}',
                  color: '#{COLORS_ARRAY[index % COLORS_ARRAY.length]}',
                  textColor: 'black'
                }"
            end.join(', ')

    respond_to do |format|
      format.html
    end

  end

end

