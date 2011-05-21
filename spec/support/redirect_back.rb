RSpec::Matchers.define :redirect_back do
  match do |response|
    response.header['Location'] == "/previous/page"
  end
end


module RSpec::Rails::RedirectableBack
  extend ActiveSupport::Concern

  included do
    before :each do
      request.env["HTTP_REFERER"] = "/previous/page"
    end
  end
end

RSpec::configure do |conf|
  conf.include RSpec::Rails::RedirectableBack, :type => :controller
end
