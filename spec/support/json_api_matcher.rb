RSpec::Matchers.define :be_valid_json_api do
  match do |json|
    Json::Api.validate(json)
  end
end
