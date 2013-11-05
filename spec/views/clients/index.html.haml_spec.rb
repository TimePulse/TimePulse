require 'spec_helper'

describe "/clients/index" do
  include ClientsHelper

  before(:each) do
    authenticate(:user)
    assign(:clients, [
      FactoryGirl.create(:client),
      FactoryGirl.create(:client)
    ])
  end

  it "renders a list of clients" do
    render

  end
end
