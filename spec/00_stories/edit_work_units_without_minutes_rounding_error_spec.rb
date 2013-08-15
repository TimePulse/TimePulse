require 'spec_helper'

steps "Minute truncation", :type => :feature do
  let! :client do Factory(:client, :name => 'Foo, Inc.') end
  let! :project do Factory(:project, :client => client) end
  let! :user      do Factory(:user, :current_project => project) end
  let! :wu     do Factory(:work_unit, {:start_time => Time.new(2013,8,1,14,54,00), 
                                       :stop_time  => Time.new(2013,8,1,18,18,45),
                                       :hours      => 3.41, :project => project, :user => user} ) end

  it "should not cause errors in the edit view" do

    visit root_path
    fill_in "Login", :with => user.login
    fill_in "Password", :with => user.password
    click_button 'Login'

    visit "/work_units/#{wu.id}/edit"
    click_button("Submit")

    page.should_not have_content("Hours must not be greater than the difference between start and stop times")
    
  end
end


