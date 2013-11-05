require 'spec_helper'

describe "/clients/show" do
  include ClientsHelper
  before(:each) do
    assign(:client, @client = FactoryGirl.create(:client))
  end

  it "succeeds" do
    render

  end
end
