require 'spec_helper'
# factory user, admin, a bunch of bills, and set a couple bills to the user.

steps "different users view the bills", :type => :feature do
  let! :user do FactoryGirl.create(:user) end
  #let! :admin do FactoryGirl.create(:admin) end
  let! :other_user do FactoryGirl.create(:user) end
  let! :my_unpaid_bill do FactoryGirl.create(:bill, :user => user) end
  let! :my_paid_bill do FactoryGirl.create(:bill, :paid_on => Date.today-1.day, :user => user) end
  let! :other_unpaid_bill do FactoryGirl.create(:bill, :user => other_user) end
  let! :other_paid_bill do FactoryGirl.create(:bill, :paid_on => Date.today-1.day, :user => other_user) end
  let! :my_unpaid_work_units do
    (0..1).to_a.map do
      FactoryGirl.create(:work_unit, :user => user, :bill => my_unpaid_bill, :hours => 10)
    end
  end
  let! :my_paid_work_units do
    (0..1).to_a.map do
      FactoryGirl.create(:work_unit, :user => user, :bill => my_paid_bill, :hours => 2)
    end
  end
  let! :other_paid_work_units do
    (0..1).to_a.map do
      FactoryGirl.create(:work_unit, :user => other_user, :bill => other_paid_bill, :hours => 5)
    end
  end
  let! :other_unpaid_work_units do
    (0..1).to_a.map do
      FactoryGirl.create(:work_unit, :user => other_user, :bill => other_unpaid_bill, :hours => 6)
    end
  end



  it "log in as a regular user" do
    visit root_path
    fill_in "Login", :with => user.login
    fill_in "Password", :with => user.password
    click_button 'Login'
  end

  it "visit the 'My Bills' page" do
    click_link 'My Bills'
  end

  it "should see my unpaid bills there" do
    within "#bill_#{my_unpaid_bill.id}" do
      page.should have_selector("td", :text => my_unpaid_bill.hours)
    end
  end

  it "should not see other user's unpaid bills there" do
    page.should_not have_selector("td", :text => other_unpaid_bill.hours)
  end

  it "clicks 'Paid' tab" do
    click_link "Paid"
  end

  it "should see my paid bills there" do
    within "#bill_#{my_paid_bill.id}" do
      page.should have_selector("td", :text => my_paid_bill.hours)
    end
  end

  it "should not see other user's paid bills there" do
    page.should_not have_selector("td", :text => other_paid_bill.hours)
  end

end