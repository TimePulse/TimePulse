class HomeController < ApplicationController
  before_filter :require_user!
  def index

    @user = current_user
    if (@current_project = current_user.current_project )
      @work_units = related_items_for(:completed_work_units, :stop_time, params[:work_unit_page])
      @commits = related_items_for(:git_commits, :time, params[:commits_page])
      @pivotal_updates = related_items_for(:pivotal_updates, :time, params[:pivotal_updates_page])
    end

  end

  private

  def related_items_for(property, order_prop, page)
    related_items = current_user.send((property.to_s + "_for").to_sym, @current_project)
    related_items = related_items.includes(:project => :client)
    related_items = related_items.order(order_prop.to_s + " DESC")
    related_items = related_items.paginate(:per_page => 10, :page => page)
  end
end
