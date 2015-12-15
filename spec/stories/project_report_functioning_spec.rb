require 'spec_helper'

shared_steps "for a task with project and work units" do
  include ChosenSelect

  let :wu_count do
    3
  end

  let :admin do
    FactoryGirl.create(:admin)
  end

  let :project do
    p = FactoryGirl.create(:project)
    p.rates << FactoryGirl.create(:rate, :amount => 150)
    p
  end

  let :archived_project do
    FactoryGirl.create(:project, :archived => true)
  end

  let :user do FactoryGirl.create(:user) end
  let! :rates_user do FactoryGirl.create(:rates_user, :rate => project.rates.last, :user => admin) end

  let! "work_units" do
    FactoryGirl.create_list(:work_unit, wu_count, :user => admin, :project => project, :hours => 3)
  end

  let :work_unit_list do
    [ FactoryGirl.create(:work_unit, :user => admin, :project => project, :hours => 4) ]
  end


  let! :invoice do
    FactoryGirl.create(:invoice, :client => project.client, :work_units => work_unit_list )
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
    page.should have_content("Total $")
    page.should have_content(project.name.upcase)
  end

  it "should have the user name and total number of hours" do
    page.should have_content("Administrator")
    page.should have_content("9.00")
    page.should have_content("1350.00")
  end

  it "should have proper table headings for user report" do
    within "#user_report" do
      page.should have_content("User")
      page.should have_content("Hours")
      page.should have_content("Total $")
    end
  end

  it "should have proper values for user report" do
    within "#user_report" do
      page.should have_content("Administrator")
      page.should have_content("9.00")
      page.should have_content("1350.00")
    end
  end

  it "should have proper table headings for rate report" do
    within "#rate_report" do
      page.should have_content("Type")
      page.should have_content("Hours")
      page.should have_content("Total $")
    end
  end

  it "should have the type name and total number of hours" do
    within "#rate_report" do
      page.should have_content("amount for name")
      page.should have_content("9.00")
      page.should have_content("1350.00")
    end
  end
  it "should list the work units for the project" do
    within "#work_unit_#{work_units[0].id}" do
      page.should have_link("Edit")
    end
    within "#work_unit_#{work_units[1].id}" do
      page.should have_link("Edit")
    end
    within "#work_unit_#{work_units[2].id}" do
      page.should have_link("Edit")
    end
  end

  it "should have the proper titles for the invoices summary" do
    within "#previous_invoices" do
      page.should have_content("Invoice #")
      page.should have_content("Date")
      page.should have_content("Hours")
      page.should have_content("Amount")
    end
  end

  it "should have the proper values for the invoices summary" do
    within "#previous_invoices" do
      page.should have_content(invoice.id)
      page.should have_content(Date.today.try(:to_s, :short_date))
      page.should have_content(4)
      page.should have_content(invoice.total)
    end
  end

  it "should link to individual invoice" do
    within "#previous_invoices" do
      page.should have_link("Show")
    end
  end

end
