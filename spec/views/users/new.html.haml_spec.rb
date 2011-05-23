require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/users/new" do
  before(:each) do
    activate_authlogic
    assign(:user, User.new)
  end

  it "should succeed" do
    render
  end

end
