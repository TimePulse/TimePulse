module ContentFor
  def content_for(name)
    view.instance_variable_get("@content_for_#{name}")
  end
end

class RSpec::Core::ExampleGroup
  include ContentFor
end
