require 'spec_helper'

describe Activity do
  let :project do Factory.create(:project) end
  let :activity do Factory.build(:activity) end

  it "should requrie a project" do
    activity.should_not be_valid
    activity.project = project
    activity.should be_valid
  end

  it "should require a source" do
    activity.project = project
    activity.should be_valid
    activity.source = nil
    activity.should_not be_valid
  end

end
