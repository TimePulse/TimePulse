class HomeController < HomePageController
  before_filter :require_user!
  def index

    @user = current_user
    if (@current_project = current_user.current_project )
      load_related_items
    end

  end

end
