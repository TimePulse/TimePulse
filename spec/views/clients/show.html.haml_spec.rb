require 'spec_helper'

describe "/clients/show" do
  include ClientsHelper
  before(:each) do
    assign(:client, @client = Factory(:client))
  end

  it "succeeds" do
    render     
    
  end
end
