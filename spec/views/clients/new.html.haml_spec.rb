require 'spec_helper'

describe "/clients/new" do
  include ClientsHelper

  before(:each) do
    assign(:client, Factory.build(:client))
  end

  it "should succeed" do
    render

  end
  it "renders new client form" do
    render
    rendered.should have_selector("form[action='#{clients_path}'][method='post']") do |scope|
    end
  end
end
