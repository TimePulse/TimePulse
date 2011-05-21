require 'spec_helper'

describe "/clients/index" do
  include ClientsHelper

  before(:each) do
    authenticate(:user)
    assign(:clients, [
      Factory(:client),
      Factory(:client)
    ])
  end

  it "renders a list of clients" do
    render

  end
end
