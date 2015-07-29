require 'spec_helper'

steps 'create a new project with repositories', :type => :feature, :snapshots_into => 'project_with_repository' do

  let! :admin do FactoryGirl.create(:admin) end
  let! :client do FactoryGirl.create(:client) end

  it 'should log in as user' do
    visit root_path
    fill_in 'Login', :with => admin.login
    fill_in 'Password', :with => admin.password
    click_button 'Login'
    page.should have_link('Logout')
  end

  it 'should navigate to the new project page' do
    click_on 'Projects'
    click_on 'New Project'
    expect(page).to have_content "New Project"
  end
  
  it 'should create a new project with a repository' do
    select client.name, from: "project_form[client_id]"

    root_project = Project.where(:name => "root").first
    page.find(:css, "#project_form_parent_idSelectBoxIt").click
    page.find(:css, "#project_form_parent_idSelectBoxItOptions [data-val='#{root_project.id}']").click

    fill_in 'Name', with: "Cool Project"
    fill_in 'project_form_repositories_attributes_0_url',
            with: "github.com/new_project"
    click_button 'Submit'
    expect(page).to have_content 'Cool Project'
  end

  it 'should edit the project' do
    click_on 'Edit'
    click_on 'Add another repository.'
    fill_in 'project_form_repositories_attributes_0_url', :with => 'github.com/feature'
    click_on 'Submit'
  end

  it 'should show the project' do
    find('a.show').click
    expect(page).to have_content 'github.com/feature'
    expect(page).to have_content 'Cool Project'
  end

  it 'should edit the project' do
    click_on 'Edit'
    click_on 'Add another repository.'
    fill_in 'project_form_repositories_attributes_1_url', :with => 'github.com/another-repository'
    click_on 'Add another repository.'
    fill_in 'project_form_repositories_attributes_2_url', :with => 'github.com/yet-another-repository'
    click_on 'Submit'
  end

  it 'should show the project' do
    find('a.show').click
    expect(page).to have_content 'github.com/feature'
    expect(page).to have_content 'github.com/another-repository'
    expect(page).to have_content 'github.com/yet-another-repository'
    expect(page).to have_content 'Cool Project'
  end

  it 'should delete a repository from the project' do
    click_on 'Edit'
    check 'project_form_repositories_attributes_2__destroy'
    click_on 'Submit'
  end

  it 'should show the project' do
    find('a.show').click
    expect(page).to     have_content 'github.com/feature'
    expect(page).to     have_content 'github.com/another-repository'
    expect(page).to_not have_content 'github.com/yet-another-repository'
    expect(page).to     have_content 'Cool Project'
  end

end