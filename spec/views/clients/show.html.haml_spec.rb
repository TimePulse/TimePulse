require 'spec_helper'

describe "/clients/show" do
  include ClientsHelper
  before(:each) do
    assigns[:client] = @client = Factory(:client)
  end

  it "succeeds" do
    render     
    response.should be_success
  end
end
