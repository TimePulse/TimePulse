require 'spec_helper'

describe "/clients/edit" do
  include ClientsHelper

  before(:each) do
    assign(:client, @client = FactoryGirl.create(:client))
  end

  it "renders the edit client form" do
    render
    rendered.should have_selector("form[action='#{client_path(@client)}'][method='post']")
  end
end
