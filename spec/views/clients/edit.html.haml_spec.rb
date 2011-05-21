require 'spec_helper'

describe "/clients/edit" do
  include ClientsHelper

  before(:each) do
    assigns[:client] = @client = Factory(:client)
  end

  it "renders the edit client form" do
    render
    response.should be_success
    response.should have_tag("form[action=#{client_path(@client)}][method=post]") 
  end
end
