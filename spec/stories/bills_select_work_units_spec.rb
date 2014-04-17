require 'spec_helper'

shared_steps "for an billing task" do |opt_hash|
  opt_hash ||= {}
  let :admin do
    FactoryGirl.create(:admin)
  end

  let :project do
    FactoryGirl.create(:project)
  end

  (opt_hash[:wu_count] || 3).times do |idx|
    let! "work_unit_#{idx}" do
      FactoryGirl.create(:work_unit, :project => project, :user => admin)
    end
  end

  it "should login as an admin" do
    visit root_path
    fill_in "Login", :with => admin.login
    fill_in "Password", :with => admin.password
    click_button 'Login'
    page.should have_link("Logout")
  end

  it "should go to bills" do
    click_link "Bills"
    page.should have_link("New Bill")
  end

  it "should create a new bills for client" do
    click_link "New Bill"
    page.select "#{admin.name} - (#{admin.work_units.unbilled.completed.billable.sum(:hours)})"
    click_button "Set Parameters"
  end
end

shared_steps "to verify bill is visible" do

  it "when I got back to the index" do
    click_link("Back to List")
  end

  it "should be visible from bills index" do
    all(:xpath, XPath.generate do |doc|
      doc.descendant(:tr)[doc.attr(:class) == "bill"]
    end).should have(1).rows
  end

  it "when I click on show" do
    within("tr.bill:nth-child(2)") do
      click_link("Show")
    end
  end

  it "should show the bill" do
    page.should have_content("Bill for #{admin.name}")
  end
end

steps "Selects all boxes", :type => :feature do
  perform_steps "for an billing task"

  it "should select all work units" do
    click_button "select all"
  end

  it "should create the bill" do
    named_submit = XPath.generate do |doc|
      doc.descendant(:form)[doc.attr(:id) == "new_bill"].descendant(:input)[doc.attr(:type) == "submit"][doc.attr(:name) == "commit"]
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

  perform_steps "to verify bill is visible"

end

steps "Select a few work units", :type => :feature do
  perform_steps "for an billing task", :wu_count => 5

  def click_checkbox(id)
    check(id)
  end

  it "should select 3 work units" do
    click_checkbox("bill_work_unit_ids_1")
    click_checkbox("bill_work_unit_ids_2")
    click_checkbox("bill_work_unit_ids_3")
  end

  it "should create the bill" do
    named_submit = XPath.generate do |doc|
      doc.descendant(:form)[doc.attr(:id) == "new_bill"].descendant(:input)[doc.attr(:type) == "submit"][doc.attr(:name) == "commit"]
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

  perform_steps "to verify bill is visible"

end
