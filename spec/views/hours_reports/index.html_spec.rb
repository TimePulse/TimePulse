require 'spec_helper'

describe "/hours_reports/index" do
  include HoursReportsHelper

  let :project do FactoryGirl.create(:project) end

  it "should succeed" do
    render
  end
end
