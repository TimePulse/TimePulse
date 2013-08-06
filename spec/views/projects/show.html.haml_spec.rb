require 'spec_helper'

describe "/projects/show" do
  include ProjectsHelper
  before(:each) do
    assign(:project, @project = Factory(:project))
    assign(:all_users, [Factory(:user)])
  end

  it "succeeds" do
    render
  end

  describe "rates" do
    before :each do
      @project.rates << Factory(:rate, :project => @project)
    end

    it "shows a rates table" do
      render
      rendered.should have_selector('table.rates')
    end

    it "shows a rate edit form" do
      render
      rendered.should have_selector("form[action='/rates/#{@project.rates.first.id}']")
    end
  end

#  describe "users drag and drop table" do
#    let!(:active_user) {Factory(:user, {:name => "Active User"}) }
#    let!(:inactive_user) {Factory(:user, {:name => "Inactive User", :inactive => true}) }

#    it "should only show active users" do
#      render
      #rendered.should have_selector("data-user-id", :text => "#{active_user.id}")
#      rendered.should have_content("#{active_user.name}")
#      rendered.should_not have_content("#{inactive_user.name}")
#    end
#  end
end
