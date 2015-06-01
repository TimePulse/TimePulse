require 'bcrypt'
class UserApiTokensController < ApplicationController
  before_filter :require_user!
  def update
    @user = current_user
    @unencrypted_token = Devise.friendly_token
    @encrypted_token = BCrypt::Password.create(@unencrypted_token)
    @user.encrypted_token = @encrypted_token
    @user.save
    render :json => {token: @unencrypted_token}
  end
end
