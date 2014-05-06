require 'spec_helper'

describe UserPreferences do
  let! :user  do FactoryGirl.create(:user) end

  it 'should have user with user_preferences' do
    user.user_preferences.should be_present
  end
end