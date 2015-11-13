require 'spec_helper'

steps 'Admin views a bill', :type => :feature do

  before do
    Timecop.travel(Time.local(2015, 4, 28, 10, 0, 0)) # Thursday Apr 28 15
  end

  let! :admin do FactoryGirl.create(:admin) end
  let! :user do FactoryGirl.create(:user) end
  let! :project do FactoryGirl.create(:project, :name => "Topmost") end
  let! :child_project do FactoryGirl.create(:project, :name => "Middle", :parent_id => project.id) end
  let! :grandchild_project do FactoryGirl.create(:project, :name => "Bottom", :parent_id => child_project.id) end
  let! :bill do FactoryGirl.create(:bill) end

  2.times do |idx|
    let! "project_work_unit_#{idx}" do
      FactoryGirl.create(:work_unit, :project => project, :user => user, :hours => 2, :bill => bill)
    end
    let! "child_project_work_unit_#{idx}" do
      FactoryGirl.create(:work_unit, :project => child_project, :user => user, :hours => 4, :bill => bill)
    end
    let! "grandchild_project_work_unit_#{idx}" do
      FactoryGirl.create(:work_unit, :project => grandchild_project, :user => user, :hours => 6, :bill => bill)
    end
  end

  it 'should log in as an admin' do
    visit root_path
    fill_in 'Login', :with => admin.login
    fill_in 'Password', :with => admin.password
    click_button 'Login'
  end

  it 'should view the bills' do
    click_on 'Reports'
    click_on 'My Bills'
  end

  it "should view the user's bill" do
    visit '/bills/1'
    expect(page).to have_content(user.name)
    expect(page).to have_content('12.0') # grandchild project
    expect(page).to have_content('8.0') # child project
    expect(page).to have_content('4.0') # parent project
    expect(page).to_not have_content('56.0') # this would be the total if the hours accumulated through the children
  end

end
