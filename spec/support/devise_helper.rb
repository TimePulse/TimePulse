module DeviseExtraTestHelper

  def current_user(stubs = {})
    return nil if current_user_session.nil?
    current_user_session.user
  end

  alias :current_person :current_user

  def current_user_session(stubs = {}, user_stubs = {})
    @current_user_session = UserSession.find
    # else
    #   @current_user_session ||= mock_model(UserSession, {:person => current_user(user_stubs)}.merge(stubs))
    # end
  end

  def login_as(user)
    user = case user
           when Symbol
             User.find_by_login(user.to_s) || FactoryGirl.create(user)
           when String
             User.find_by_login(user)
           else
             user
           end
    sign_in user
    user
  end
  alias authenticate login_as

  def verify_authorization_successful
    response.should_not redirect_to(login_path)
  end

  def verify_authorization_unsuccessful
    response.should redirect_to(login_path)
  end

end

module RSpec::Rails::ControllerExampleGroup
  include DeviseExtraTestHelper
end

module RSpec::Rails::ViewExampleGroup
  include DeviseExtraTestHelper
end

module RSpec::Rails::HelperExampleGroup
  include DeviseExtraTestHelper
end
