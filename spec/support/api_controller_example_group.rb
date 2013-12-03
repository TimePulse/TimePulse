require 'spec_helper'

module ApiControllerExampleGroup
  class RequestTokenAdder
    def initialize(token)
      @token = token
    end

    def to(request)
      request.env['HTTP_AUTHORIZATION'] = "Bearer #{@token.token}"
    end
  end

  def add_token_for(user)
    @client = FactoryGirl.create(:oauth_client)
    @token = Devise::Oauth2Providable::AccessToken.create! :client => @client, :user => user
    RequestTokenAdder.new(@token)
  end

  RSpec.configure do |config|
    config.include self,
      :type => :controller,
      :example_group => { :file_path => %r(spec/controllers/api) }
  end
end