require 'spec_helper'

shared_steps "for a task with project and work units" do |opt_hash|
  include ChosenSelect
  opt_hash ||= {}

  let :admin do
    FactoryGirl.create(:admin)
  end
  
  let :project do
    FactoryGirl.create(:project)
  end

  let :user do FactoryGirl.create(:user) end
  let! :rates_user do FactoryGirl.create(:rates_user, :rate => project.rates.last, :user => admin) end

  (opt_hash[:wu_count] || 3).times do |idx|
    let! "work_unit_#{idx}" do
      FactoryGirl.create(:work_unit, :user => admin, :project => project, :hours => 3)
    end
    
  end

  it "should login as an admin" do
    visit root_path
    fill_in "Login", :with => admin.login
    fill_in "Password", :with => admin.password
    click_button 'Login'
    page.should have_link("Logout")
  end

end

steps "the project reports page", :type => :feature do
  perform_steps "for a task with project and work units"
  
  it "should have proper content" do
    visit "/project_reports/new"
    
    page.should have_content("Project Report")
    page.should have_content("REPORT PARAMETERS")
  end
  
  it "should be able to select a project" do
    select_from_chosen(project.name,:from => 'project_id')
    click_button "Select Project"
  end
  
  it "should have the proper titles" do
    page.should have_content("User")
    page.should have_content("Hours")
    page.should have_content(project.name.upcase)
  end
  
  it "should have the user name and total number of hours" do
    page.should have_content("Administrator")
    page.should have_content("9")
  end
  
  it "should list the work units for the project" do
    within "#work_unit_#{work_unit_0.id}" do
      page.should have_link("Edit")
    end
    within "#work_unit_#{work_unit_1.id}" do
      page.should have_link("Edit")
    end
    within "#work_unit_#{work_unit_2.id}" do
      page.should have_link("Edit")
    end
  end
    
end

