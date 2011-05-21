require 'spec_helper'

describe "/projects/show" do
  include ProjectsHelper
  before(:each) do
    assigns[:project] = @project = Factory(:project)
  end

  it "succeeds" do
    render
    response.should be_success
  end
end
