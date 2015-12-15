require 'spec_helper'

steps "log in and switch projects", :type => :feature, :firefox => false do

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

  it "should switch to manual time entry when tab is clicked" do
    within "#work_unit_entry" do
      page.should have_content("Manual Time Entry")
      find('#work_unit_entry_tp_manual_time_entry_tab').click
    end
  end

  # XXX Firefox can't find #work_unit_form, which breaks firefox runs
  # Travis is only Firefox so...
  it "should have a work unit form (XPath Gem format)" do
    within "#work_unit_form" do
      page.should have_xpath(XPath.generate do |doc|
         doc.descendant(:form)[doc.attr(:id) == "manual_new_work_unit"][doc.attr(:action) == '/work_units']
      end)
    end
  end

  it "should have a work unit form (Plain XPath format)" do
    page.should have_xpath("//form[@id='manual_new_work_unit'][@action='/work_units']")
  end

  it "should have a work unit form (have_selector format)" do
    page.should have_selector("form#manual_new_work_unit[action='/work_units']")
  end


  it "should have the name of the project" do
    within "#work_unit_form" do
      within "h2.toggler" do
        page.should have_content(project_1.name.upcase)
      end
    end
  end

  it "should list project 1's work units " do
    project_1.work_units.each do |work_unit|
      xp = "//*[@id='work_report_tp_work_units_pane']//td[contains(.,'#{work_unit.notes}')]"
      page.should have_xpath(xp)
    end
  end

  it "should not list project 2's work units" do
    project_2.work_units.each do |work_unit|
      page.should_not have_xpath("//*[@id='work_report_tp_work_units_pane']//td[contains(.,'#{work_unit.notes}')]")
    end
  end

  it "should have a timeclock with the name of the project" do
    find('#work_unit_entry_tp_timeclock_tab').click
    within "#timeclock" do
      page.should have_content(project_1.name)
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
    find('#work_unit_entry_tp_manual_time_entry_tab').click
    within "#work_unit_form" do
      within "h2.toggler" do
        page.should have_content(project_2.name.upcase)
      end
    end
  end

  it "should have a timeclock with the name of the project" do
    find('#work_unit_entry_tp_timeclock_tab').click
    within "div#timeclock" do
      page.should have_content(project_2.name)
    end
  end

  it "when the page is reloaded" do
    visit(current_path)
    find('#work_unit_entry_tp_manual_time_entry_tab').click
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
    find('#work_unit_entry_tp_timeclock_tab').click
    within "div#timeclock" do
      page.should have_content(project_2.name)
    end
  end
end
