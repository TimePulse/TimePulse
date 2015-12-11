require 'spec_helper'

shared_steps "for an invoicing task" do
  let :admin do
    FactoryGirl.create(:admin)
  end

  let :project do
    FactoryGirl.create(:project)
  end

  let :junior_rate do
    FactoryGirl.create(:rate, :name => "a raw pittance", :project => project, :amount => 15)
  end

  let :junior_dev do FactoryGirl.create(:user, :login => "plebian") end

  let! :rates_junior_dev do FactoryGirl.create(:rates_user, :rate => junior_rate, :user => junior_dev) end

  let :senior_rate do
    FactoryGirl.create(:rate, :name => "rolls royce baby", :project => project, :amount => 10000)
  end

  let :senior_dev do FactoryGirl.create(:user, :login => "mrfancy") end

  let! :rates_senior_dev do FactoryGirl.create(:rates_user, :rate => senior_rate, :user => senior_dev) end

  let! "junior_work_units" do
    FactoryGirl.create_list(:work_unit, wu_count, :hours => 5, :user => junior_dev, :project => project)
  end

  let! "senior_work_units" do
    FactoryGirl.create_list(:work_unit, wu_count, :hours => 5, :user => senior_dev, :project => project)
  end

  it "should login as an admin" do
    visit root_path
    fill_in "Login", :with => admin.login
    fill_in "Password", :with => admin.password
    click_button 'Login'
    page.should have_link("Logout")
  end

  it "should go to invoices" do
    click_link "Invoices"
    page.should have_link("New Invoice")
  end

  it "should create a new invoice for client" do
    click_link "New Invoice"
    page.select project.client.name
    click_button "Set Parameters"
  end
end


steps "Selects all boxes", :type => :feature do
  let :wu_count do
    3
  end

  perform_steps "for an invoicing task"

  it "should select all work units" do
    click_button "select all"
  end

  it "should create the invoice" do
    named_submit = XPath.generate do |doc|
      doc.descendant(:form)[doc.attr(:id) == "new_invoice"].descendant(:input)[doc.attr(:type) == "submit"][doc.attr(:name) == "commit"]
    end
    button = find(:xpath, named_submit)
    button.click
  end

  it "should look right" do
    page.should_not have_xpath(XPath.generate do |doc|
      doc.descendant(:title)[doc.contains("Exception")]
    end.to_s)

    all(:xpath, XPath.generate do |doc|
      doc.descendant(:tr)[doc.attr(:class) == "work_unit"]
    end).should have(6).rows
  end
end

steps "Select a few work units", :type => :feature do
  let :wu_count do
    5
  end

  perform_steps "for an invoicing task"

  it "should select 3 work units" do
    check("invoice_work_unit_ids_1")
    check("invoice_work_unit_ids_2")
    check("invoice_work_unit_ids_3")
  end

  it "should create the invoice" do
    named_submit = XPath.generate do |doc|
      doc.descendant(:form)[doc.attr(:id) == "new_invoice"].descendant(:input)[doc.attr(:type) == "submit"][doc.attr(:name) == "commit"]
    end
    button = find(:xpath, named_submit)
    button.click
  end

  it "should look right" do
    page.should_not have_xpath(XPath.generate do |doc|
      doc.descendant(:title)[doc.contains("Exception")]
    end.to_s)

    all(:xpath, XPath.generate do |doc|
      doc.descendant(:tr)[doc.attr(:class) == "work_unit"]
    end).should have(3).rows
  end

end

steps "invoice totals", :type => :feature do
  let :wu_count do
    5
  end

  perform_steps "for an invoicing task"

  let :senior_dev_wu_id do
    "invoice_work_unit_ids_#{senior_work_units[1].id}"
  end

  let :junior_dev_wu_id_1 do
    "invoice_work_unit_ids_#{junior_work_units[1].id}"
  end

  let :junior_dev_wu_id_2 do
    "invoice_work_unit_ids_#{junior_work_units[2].id}"
  end

  it "should select 3 work units" do
    check(senior_dev_wu_id)
    check(junior_dev_wu_id_1)
    check(junior_dev_wu_id_2)
  end

  it "should have a totals table" do
    page.should have_css("table#totals")
  end

  it "should show the senior totals" do
    within "table#totals" do
      within "tr#rate_#{senior_rate.id}" do
        page.should have_content("rolls royce baby")
        page.should have_content("5.00")
        page.should have_content("50000.00")
      end
    end
  end


  it "should show the junior totals" do
    within "table#totals" do
      within "tr#rate_#{junior_rate.id}" do
        page.should have_content("a raw pittance")
        page.should have_content("10.00")
        page.should have_content("150.00")
      end
    end
  end

  it "should show the junior totals" do
    within "table#totals" do
      within "tr#rate_total" do
        page.should have_content("Totals")
        page.should have_content("15.00")
        page.should have_content("50150.00")
      end
    end
  end

end
