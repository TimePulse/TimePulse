module AuthlogicTestHelper

  def current_user(stubs = {})
    return nil if current_user_session.nil?
    current_user_session.user
  end

  alias :current_person :current_user

  def current_user_session(stubs = {}, user_stubs = {}) 
    @current_user_session = UserSession.find
  end    

  def login_as(user)
    user = Factory(user) if user.is_a?(Symbol)
    @current_session = UserSession.create(user)
    user
  end

  def logout
    @current_user_session = nil
    UserSession.find.destroy if UserSession.find
  end

  def activate_and_login(user)
    activate_authlogic
    login_as(user)
  end               
  alias_method :authenticate, :activate_and_login
end
