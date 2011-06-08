class HomeController < AuthzController
  def index
    @user = current_user
  end
end
