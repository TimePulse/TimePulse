require 'json/api'

RSpec::Matchers.define :be_valid_json_api do
  match do |json|
    JSON::Api.validate(json)
  end
end
