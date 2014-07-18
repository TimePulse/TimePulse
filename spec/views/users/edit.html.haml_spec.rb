require 'spec_helper'

describe "/users/edit" do
  before(:each) do
    assign(:user, User.new)
    authenticate(:user)
  end

  it "does not show the inactive check box to non-admin users" do
    render
    rendered.should_not have_selector('input#user_inactive')
  end

  it "does show the inactive check box to admin users" do
    assign(:admin, User.new)
    authenticate(:admin)
    render
    rendered.should have_selector('input#user_inactive')
  end
end
