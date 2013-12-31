class HomeController < HomePageController
  before_filter :require_user!
  def index

    @user = current_user
    if (@current_project = current_user.current_project )
      load_related_items
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
