require 'spec_helper'

describe "/projects/show" do
  include ProjectsHelper
  before(:each) do
    assign(:project, @project = Factory(:project))
  end

  it "succeeds" do
    render
  end
end
