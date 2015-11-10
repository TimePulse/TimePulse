require 'spec_helper'

steps "log in and switch projects", :type => :feature do

  let! :client_1 do FactoryGirl.create(:client, :name => 'Foo, Inc.') end
  let! :client_2 do FactoryGirl.create(:client, :name => 'Bar, Inc.') end
  let! :project_1 do FactoryGirl.create(:project, :client => client_1) end
  let! :project_2 do FactoryGirl.create(:project, :client => client_2) end
  let! :user      do FactoryGirl.create(:user, :current_project => project_1) end

  let! :work_units do
    [ FactoryGirl.create(:work_unit_with_annotation, :project => project_1,
                         :user => user, :description => "Note 1"),
      FactoryGirl.create(:work_unit_with_annotation, :project => project_1,
                         :user => user, :description => "Note 2"),
      FactoryGirl.create(:work_unit_with_annotation, :project => project_1,
                         :user => user, :description => "Note 3"),
      FactoryGirl.create(:work_unit_with_annotation, :project => project_2,
                         :user => user, :description => "Note 4"),
      FactoryGirl.create(:work_unit_with_annotation, :project => project_2,
                         :user => user, :description => "Note 5"),
      FactoryGirl.create(:work_unit_with_annotation, :project => project_2,
                         :user => user, :description => "Note 6")
    ]
  end

  it "should login as a user" do
    visit root_path
    fill_in "Login", :with => user.login
    fill_in "Password", :with => user.password
    click_button 'Login'
    page.should have_link("Logout")
  end

  it "should expand the manual time entry work unit form" do
    click_link "(+ show manual time entry)"
  end

  it "should have a work unit form (XPath Gem format)" do
    page.should have_xpath(XPath.generate do |doc|
       doc.descendant(:form)[doc.attr(:id) == "new_work_unit"][doc.attr(:action) == '/work_units']
    end)
  end

  it "should have a work unit form (Plain XPath format)" do
    page.should have_xpath("//form[@id='new_work_unit'][@action='/work_units']")
  end

  it "should have a work unit form (have_selector format)" do
    page.should have_selector("form#new_work_unit[action='/work_units']")
  end


  it "should have the name of the project" do
    within "#work_unit_form" do
      within "h2.toggler" do
        page.should have_content(project_1.name.upcase)
      end
    end
  end

  it "should have a timeclock with the name of the project" do
    within "#timeclock" do
      page.should have_content(project_1.name)
    end
  end

  it "should list project 1's work units " do
    project_1.work_units.each do |work_unit|
      xp = "//*[@id='current_project']//td[contains(.,'#{work_unit.notes}')]"
      page.should have_xpath(xp)
    end
  end

  it "should not list project 2's work units" do
    project_2.work_units.each do |work_unit|
      page.should_not have_xpath("//*[@id='current_project']//td[contains(.,'#{work_unit.notes}')]")
    end
  end

  it "project 1 should have css class 'current'" do
    page.should have_selector("#project_picker #project_#{project_1.id}.current")
  end

  it "project 2 should not have class 'current'" do
    page.should_not have_selector("#project_picker #project_#{project_2.id}.current")
  end

  it "when I click project 2" do
    click_link project_2.name
  end

  it "project 2 should have css class 'current'" do
    page.should have_selector("#project_picker #project_#{project_2.id}.current")
  end

  it "project 1 should not have class 'current'" do
    page.should_not have_selector("#project_picker #project_#{project_1.id}.current")
  end

  it "should have the name of project 2" do
    within "#work_unit_form" do
      within "h2.toggler" do
        page.should have_content(project_2.name.upcase)
      end
    end
  end

  it "should have a timeclock with the name of the project" do
    within "div#timeclock" do
      page.should have_content(project_2.name)
    end
  end

  it "when the page is reloaded" do
    visit(current_path)
    click_link "(+ show manual time entry)"
  end

  it "project 2 should have css class 'current'" do
    page.should have_selector("#project_picker #project_#{project_2.id}.current")
  end

  it "project 1 should not have class 'current'" do
    page.should_not have_selector("#project_picker #project_#{project_1.id}.current")
  end

  it "should have the name of project 2" do
    within "#work_unit_form" do
      within "h2.toggler" do
        page.should have_content(project_2.name.upcase)
      end
    end
  end

  it "should have a timeclock with the name of the project" do
    within "div#timeclock" do
      page.should have_content(project_2.name)
    end
  end

end
