require 'spec_helper'


steps "trivial story", :type => :feature do
  it "should visit the root" do
    visit root_path
  end
end

