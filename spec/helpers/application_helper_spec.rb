require 'spec_helper'

describe ApplicationHelper do

  describe "#project_options" do

    let :archived_projects do
      projects = []
      5.times do
        projects << FactoryGirl.create(:project, archived: true)
      end
      projects
    end
    let :unarchived_projects do
      projects = []
      5.times do
        projects << FactoryGirl.create(:project, archived: false)
      end
      projects
    end
    let! :all_projects do
      archived_projects + unarchived_projects
    end
    let :project_option_ids do
      ids = []
      subject.each do |row|
        ids << row[1]
      end
      ids
    end

    context "displaying only unarchived projects (default)" do

      subject { project_options }

      it "should include root" do
        expect(project_option_ids).to include(1)
      end

      it "should include ids of all unarchived projects" do
        expect(project_option_ids).to include(*unarchived_projects.map(&:id))
      end

      it "should not include ids of archived projects" do
        expect(project_option_ids).to_not include(*archived_projects.map(&:id))
      end

    end

    context "displaying all projects" do

      subject { project_options(true) }

      it "should include root" do
        expect(project_option_ids).to include(1)
      end

      it "should include ids of all projects" do
        expect(project_option_ids).to include(*all_projects.map(&:id))
      end

    end
  end

end
