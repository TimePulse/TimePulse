require 'spec_helper'

describe "/clients/new" do
  include ClientsHelper

  before(:each) do
    assigns[:client] = Factory.build(:client)
  end
         
  it "should succeed" do                       
    render              
    response.should be_success    
  end
  it "renders new client form" do
    render
    response.should have_tag("form[action=?][method=post]", clients_path) do
    end
  end
end
