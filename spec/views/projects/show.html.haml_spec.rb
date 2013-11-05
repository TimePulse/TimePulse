require 'spec_helper'

describe "/projects/show" do
  include ProjectsHelper
  before(:each) do
    assign(:project, @project = FactoryGirl.create(:project))
    assign(:active_users, [FactoryGirl.create(:user)])
  end

  it "succeeds" do
    render
  end

  describe "rates" do
    before :each do
      @project.rates << FactoryGirl.create(:rate, :project => @project)
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
end
