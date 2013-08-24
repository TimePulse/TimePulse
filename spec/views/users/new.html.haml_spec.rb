require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/users/new" do
  before(:each) do
    assign(:user, User.new)
    # not needed for this spec, but needed so that the user form will not cause the spec to fail
    authenticate(:user)
  end

  it "should succeed" do
    render
  end

  it "should not let non-admin users create an inactive user" do
    render
    rendered.should_not have_selector('input#user_inactive')
  end

  it "should let an admin set the inactive flag when creating a user" do
    assign(:admin, User.new)
    authenticate(:admin)
    render
    rendered.should have_selector('input#user_inactive')
  end
end
